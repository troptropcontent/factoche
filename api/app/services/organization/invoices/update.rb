module Organization
  module Invoices
    class Update
      class << self
        def call(invoice_id, params)
          invoice, project_version, project, client, company = load_ressouces!(invoice_id)

          validated_params = validate_params!(params)

          ensure_invoice_is_draft!(invoice)

          ensure_original_item_uuid_belongs_to_project_version!(project_version, validated_params["invoice_amounts"])

          ensure_invoiced_item_remains_within_limits!(validated_params["invoice_amounts"], project_version.items, project.id, company.id)

          accounting_service_arguments = build_accounting_service_arguments(company, client, project, project_version, validated_params["invoice_amounts"])

          invoice = update_invoice!([ invoice_id, *accounting_service_arguments ])

          ServiceResult.success(invoice)
        rescue StandardError => e
          ServiceResult.failure("Failed to update invoice : #{e}, #{e.backtrace}")
        end

        private

        def load_ressouces!(invoice_id)
          invoice = Accounting::Invoice.find(invoice_id)
          project_version = ProjectVersion.find(invoice.holder_id)
          project = project_version.project
          client = project.client
          company = client.company

          [ invoice, project_version, project, client, company ]
        end

        def validate_params!(params)
          contract = UpdateContract.new.call(params)
          unless contract.success?
            raise Error::UnprocessableEntityError, "Invalid completion snapshot invoice parameters"
          end
          contract.to_h.with_indifferent_access
        end

        def ensure_invoice_is_draft!(invoice)
          unless invoice.draft?
            raise Error::UnprocessableEntityError, "Cannot update invoice that is not in draft status"
          end
        end

        def ensure_original_item_uuid_belongs_to_project_version!(project_version, invoice_amounts)
          existing_uuids = Organization::Item
            .where(project_version_id: project_version.id)
            .where(original_item_uuid: invoice_amounts.map { |ia| ia[:original_item_uuid] })
            .pluck(:original_item_uuid)
            .to_set

          invalid_uuids = invoice_amounts.map { |ia| ia[:original_item_uuid] }.reject { |uuid| existing_uuids.include?(uuid) }

          if invalid_uuids.any?
            raise Error::UnprocessableEntityError, "All invoice amounts must reference items that exist in the project version"
          end
        end

        def ensure_invoiced_item_remains_within_limits!(invoice_amounts, items, project_id, company_id)
          result = Projects::GetInvoicedAmountForProjectItems.call(company_id, project_id)
          raise Error::UnprocessableEntityError, result.error if result.failure?

          items_by_uuid = items.index_by(&:original_item_uuid)
          wrong_invoice_amount = invoice_amounts.find { |invoice_amount|
            item = items_by_uuid[invoice_amount["original_item_uuid"]]
            item_amount = item.quantity * item.unit_price_amount
            previously_invoiced_amount = result.data.find { |invoiced_amount| invoiced_amount[:original_item_uuid] == invoice_amount["original_item_uuid"] }[:invoiced_amount]
            item_amount_after_invoice = previously_invoiced_amount + invoice_amount["invoice_amount"].to_d
            (item_amount_after_invoice - item_amount).round(2) > 0
          }

          if wrong_invoice_amount
            raise Error::UnprocessableEntityError, "Invoice amount would exceed item total amount for item #{wrong_invoice_amount[:original_item_uuid]}"
          end
        end

        def build_accounting_service_arguments(company, client, project, project_version, invoice_amounts)
          company_hash = {
            id: company.id,
            name: company.name,
            registration_number: company.registration_number,
            address_zipcode: company.address_zipcode,
            address_street: company.address_street,
            address_city: company.address_city,
            vat_number: company.vat_number,
            phone: company.phone,
            email: company.email,
            rcs_city: company.rcs_city,
            rcs_number: company.rcs_number,
            legal_form: company.legal_form,
            capital_amount: company.capital_amount,
            config: {
              payment_term_days: company.config.payment_term_days,
              payment_term_accepted_methods: company.config.payment_term_accepted_methods,
              general_terms_and_conditions:  company.config.general_terms_and_conditions
            }
          }

          client_hash = {
            name: client.name,
            registration_number: client.registration_number,
            address_zipcode: client.address_zipcode,
            address_street: client.address_street,
            address_city: client.address_city,
            vat_number: client.vat_number,
            phone: client.phone,
            email: client.email
          }

          project_hash = {
            name: project.name
          }

          project_version_hash = {
            id: project_version.id,
            number: project_version.number,
            created_at: project_version.created_at,
            retention_guarantee_rate: project_version.retention_guarantee_rate / 10000.to_d,
            items: project_version.items.map { |item|
              {
                original_item_uuid: item.original_item_uuid,
                name: item.name,
                description: item.description,
                quantity: item.quantity,
                unit: item.unit,
                unit_price_amount: item.unit_price_amount,
                tax_rate: item.tax_rate,
                group_id: item.item_group_id
              }
            },
            item_groups: project_version.item_groups.map { |item_group|
              {
                id: item_group.id,
                name: item_group.name,
                description: item_group.description
              }
            }
          }

          [ company_hash, client_hash, project_hash, project_version_hash, invoice_amounts ]
        end

        def update_invoice!(args)
          result = Accounting::Invoices::Update.call(*args)

          if result.failure?
            raise result.error
          end

          result.data
        end
      end
    end
  end
end
