module Organization
  module Proformas
    class Create
      include ApplicationService

      def call(project_version_id, params)
        load_resources!(project_version_id)

        validate_params!(params)

        ensure_project_version_is_the_last_one!

        ensure_no_other_draft!

        ensure_original_item_uuid_belongs_to_project_version!

        ensure_invoiced_item_remains_within_limits!

        find_snapshot_number!

        create_proforma!(@validated_params[:issue_date] || Time.current)
      end

      private

      def find_snapshot_number!
        result = Invoices::FindNextSnapshotNumber.call(@project.id)
        raise result.error if result.failure?

        @snapshot_number = result.data
      end

      def validate_params!(params)
        @validated_params = validate!(params, CreateContract)
      end

      def load_resources!(project_version_id)
        @project_version = ProjectVersion.find(project_version_id)
        @project = @project_version.project
        @client = @project.client
        @company = @client.company
      end

      def ensure_project_version_is_the_last_one!
        unless @project_version.is_last_version?
          raise Error::UnprocessableEntityError, "Can only create completion snapshot invoice from the last version of a project"
        end
      end

      def ensure_original_item_uuid_belongs_to_project_version!
        unless @validated_params["invoice_amounts"].all? { |invoice_amount|
          @project_version.items.where({ original_item_uuid: invoice_amount["original_item_uuid"] }).exists?
        }
          raise Error::UnprocessableEntityError, "All invoice amounts must reference items that exist in the project version"
        end
      end

      def ensure_invoiced_item_remains_within_limits!
        result = Orders::FetchInvoicedAmountPerItems.call(@project.id)
        raise result.error if result.failure?

        invoice_amounts = @validated_params["invoice_amounts"]

        items_by_uuid = @project_version.items.index_by(&:original_item_uuid)
        wrong_invoice_amount = invoice_amounts.find { |invoice_amount|
          item = items_by_uuid[invoice_amount["original_item_uuid"]]
          item_amount = item.quantity * item.unit_price_amount
          previously_invoiced_amount = result.data.dig(item.original_item_uuid, :invoices_amount) - result.data.dig(item.original_item_uuid, :credit_notes_amount)
          item_amount_after_invoice = previously_invoiced_amount + invoice_amount["invoice_amount"].to_d
          (item_amount_after_invoice - item_amount).round(2) > 0
        }

        if wrong_invoice_amount
          raise Error::UnprocessableEntityError, "Invoice amount would exceed item total amount for item #{wrong_invoice_amount[:original_item_uuid]}"
        end
      end

      def build_accounting_service_arguments(issue_date)
        company_hash = {
          id: @company.id,
          name: @company.name,
          registration_number: @company.registration_number,
          address_zipcode: @company.address_zipcode,
          address_street: @company.address_street,
          address_city: @company.address_city,
          vat_number: @company.vat_number,
          rcs_city: @company.rcs_city,
          rcs_number: @company.rcs_number,
          legal_form: @company.legal_form,
          capital_amount: @company.capital_amount,
          phone: @company.phone,
          email: @company.email,
          config: {
            payment_term_days: @company.config.payment_term_days,
            payment_term_accepted_methods: @company.config.payment_term_accepted_methods,
            general_terms_and_conditions:  @company.config.general_terms_and_conditions
          },
          bank_detail: {
            iban: @project.bank_detail.iban,
            bic: @project.bank_detail.bic
          }
        }

        client_hash = {
          id: @client.id,
          name: @client.name,
          registration_number: @client.registration_number,
          address_zipcode: @client.address_zipcode,
          address_street: @client.address_street,
          address_city: @client.address_city,
          vat_number: @client.vat_number,
          phone: @client.phone,
          email: @client.email
        }

        project_hash = {
          name: @project.name
        }

        project_version_hash = {
          id: @project_version.id,
          number: @project_version.number,
          created_at: @project_version.created_at,
          retention_guarantee_rate: @project_version.retention_guarantee_rate,
          items: @project_version.items.map { |item|
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
          item_groups: @project_version.item_groups.map { |item_group|
            {
              id: item_group.id,
              name: item_group.name,
              description: item_group.description
            }
          }
        }

        {
          company: company_hash,
          client: client_hash,
          project: project_hash,
          project_version: project_version_hash,
          new_invoice_items: @validated_params["invoice_amounts"],
          snapshot_number: @snapshot_number,
          issue_date: issue_date
        }
      end

      def create_proforma!(issue_date)
        accounting_service_arguments = build_accounting_service_arguments(issue_date)

        result = Accounting::Proformas::Create.call(accounting_service_arguments)

        if result.failure?
          raise result.error
        end

        result.data
      end

      def ensure_no_other_draft!
        raise "Cannot create a new proforma invoice while another draft proforma invoice exists for this project" if Accounting::Proforma.where(holder_id: @project.versions.pluck(:id)).draft.any?
      end
    end
  end
end
