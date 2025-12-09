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

        ensure_discount_amounts_remain_within_limits! if @validated_params["discount_amounts"].present?

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

      def ensure_discount_amounts_remain_within_limits!
        # Fetch previously invoiced discount amounts
        result = Orders::FetchInvoicedAmountPerItems.call(@project.id, @validated_params[:issue_date] || Time.current)
        raise result.error if result.failure?

        discount_amounts = @validated_params["discount_amounts"]
        discounts_by_uuid = @project_version.discounts.index_by(&:original_discount_uuid)

        # Validate each discount amount
        discount_amounts.each do |discount_amount|
          uuid = discount_amount["original_discount_uuid"]
          amount = discount_amount["discount_amount"].to_d

          # Find the discount in project version
          discount = discounts_by_uuid[uuid]
          unless discount
            raise Error::UnprocessableEntityError, "Discount with UUID #{uuid} not found in project version"
          end

          # Calculate previously applied discount (as negative amount)
          previously_applied = result.data.dig(uuid, :invoices_amount).to_d - result.data.dig(uuid, :credit_notes_amount).to_d

          # Total discount available (as positive amount)
          total_discount = discount.amount.abs

          # Remaining discount (subtract absolute value of previously applied)
          remaining_discount = total_discount - previously_applied.abs

          # Check if proposed amount exceeds remaining (with small tolerance for rounding)
          tolerance = 0.01
          if amount > (remaining_discount + tolerance)
            raise Error::UnprocessableEntityError,
              "Discount amount #{amount} exceeds remaining discount of #{remaining_discount.round(2)} " \
              "for '#{discount.name}' (total: #{total_discount}, previously applied: #{previously_applied.abs.round(2)})"
          end

          # Warn if significantly under-applying (less than 80% of remaining)
          under_application_threshold = 0.8
          if remaining_discount > 0 && amount < (remaining_discount * under_application_threshold)
            Rails.logger.warn(
              "Discount '#{discount.name}' (#{uuid}) is being significantly under-applied: " \
              "#{amount} out of remaining #{remaining_discount.round(2)}"
            )
          end
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
          name: @project.name,
          address_zipcode: @project.address_zipcode,
          address_street: @project.address_street,
          address_city: @project.address_city,
          po_number: @project.po_number
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
          },
          discounts: @project_version.discounts.ordered.map { |discount|
            {
              original_discount_uuid: discount.original_discount_uuid,
              kind: discount.kind,
              value: discount.value,
              amount: discount.amount,
              position: discount.position,
              name: discount.name
            }
          }
        }

        args = {
          company: company_hash,
          client: client_hash,
          project: project_hash,
          project_version: project_version_hash,
          new_invoice_items: @validated_params["invoice_amounts"],
          snapshot_number: @snapshot_number,
          issue_date: issue_date
        }

        # Add discount amounts if provided
        if @validated_params["discount_amounts"].present?
          args[:new_invoice_discounts] = @validated_params["discount_amounts"]
        end

        args
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
