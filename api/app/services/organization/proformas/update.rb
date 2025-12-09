module Organization
  module Proformas
    class Update
      include ApplicationService

      def call(proforma_id, params)
        load_ressouces!(proforma_id)

        validate_params!(params)

        ensure_proforma_is_draft!

        ensure_original_item_uuid_belongs_to_order_version!

        ensure_invoiced_item_remains_within_limits!

        ensure_discount_amounts_remain_within_limits! if @validated_params["discount_amounts"].present?

        update_proforma!(@validated_params[:issue_date] || Time.current)
      end

      private

      def load_ressouces!(proforma_id)
        @proforma = Accounting::Proforma.find(proforma_id)
        @order_version = ProjectVersion.find(@proforma.holder_id)
        @order = @order_version.project
        @client = @order.client
        @company = @client.company
      end

      def validate_params!(params)
        @validated_params = validate!(params, UpdateContract)
      end

      def ensure_proforma_is_draft!
        unless @proforma.draft?
          raise Error::UnprocessableEntityError, "Cannot update proforma that is not in draft status"
        end
      end

      def ensure_original_item_uuid_belongs_to_order_version!
        existing_uuids = Organization::Item
          .where(project_version_id: @order_version.id)
          .where(original_item_uuid: @validated_params[:invoice_amounts].map { |ia| ia[:original_item_uuid] })
          .pluck(:original_item_uuid)
          .to_set

        invalid_uuids = @validated_params[:invoice_amounts].map { |ia| ia[:original_item_uuid] }.reject { |uuid| existing_uuids.include?(uuid) }

        if invalid_uuids.any?
          raise Error::UnprocessableEntityError, "All invoice amounts must reference items that exist in the project version"
        end
      end

      def ensure_invoiced_item_remains_within_limits!
        result = Orders::FetchRemainingAmountToInvoicePerItems.call(@order.id)
        raise result.error if result.failure?

        invoice_amounts = @validated_params["invoice_amounts"]
        remaining_amounts_per_items = result.data

        wrong_invoice_amount = invoice_amounts.find { |new_invoice_amount|
          original_item_uuid =  new_invoice_amount["original_item_uuid"]
          remaining_amount_to_invoice_for_this_item = remaining_amounts_per_items[original_item_uuid]
          invoice_amount = new_invoice_amount["invoice_amount"]

          (remaining_amount_to_invoice_for_this_item - invoice_amount).round(2) < 0
        }

        if wrong_invoice_amount
          raise Error::UnprocessableEntityError, "Invoice amount would exceed item total amount for item #{wrong_invoice_amount[:original_item_uuid]}"
        end
      end

      def ensure_discount_amounts_remain_within_limits!
        # Fetch previously invoiced discount amounts
        result = Orders::FetchInvoicedAmountPerItems.call(@order.id, @validated_params[:issue_date] || Time.current)
        raise result.error if result.failure?

        discount_amounts = @validated_params["discount_amounts"]
        discounts_by_uuid = @order_version.discounts.index_by(&:original_discount_uuid)

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

      def build_accounting_service_arguments!(issue_date)
        company_hash = {
          id: @company.id,
          name: @company.name,
          registration_number: @company.registration_number,
          address_zipcode: @company.address_zipcode,
          address_street: @company.address_street,
          address_city: @company.address_city,
          vat_number: @company.vat_number,
          phone: @company.phone,
          email: @company.email,
          rcs_city: @company.rcs_city,
          rcs_number: @company.rcs_number,
          legal_form: @company.legal_form,
          capital_amount: @company.capital_amount,
          config: {
            payment_term_days: @company.config.payment_term_days,
            payment_term_accepted_methods: @company.config.payment_term_accepted_methods,
            general_terms_and_conditions:  @company.config.general_terms_and_conditions
          },
          bank_detail: {
            iban: @order.bank_detail.iban,
            bic: @order.bank_detail.bic
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
          name: @order.name,
          address_zipcode: @order.address_zipcode,
          address_street: @order.address_street,
          address_city: @order.address_city,
          po_number: @order.po_number
        }

        project_version_hash = {
          id: @order_version.id,
          number: @order_version.number,
          created_at: @order_version.created_at,
          retention_guarantee_rate: @order_version.retention_guarantee_rate / 10000.to_d,
          items: @order_version.items.map { |item|
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
          item_groups: @order_version.item_groups.map { |item_group|
            {
              id: item_group.id,
              name: item_group.name,
              description: item_group.description
            }
          },
          discounts: @order_version.discounts.ordered.map { |discount|
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
          proforma_id: @proforma.id,
          company: company_hash,
          client: client_hash,
          project: project_hash,
          project_version: project_version_hash,
          new_invoice_items: @validated_params[:invoice_amounts],
          issue_date: issue_date,
          snapshot_number: @proforma.context["snapshot_number"]
        }

        # Add discount amounts if provided
        if @validated_params["discount_amounts"].present?
          args[:new_invoice_discounts] = @validated_params["discount_amounts"]
        end

        args
      end

      def update_proforma!(issue_date)
        args = build_accounting_service_arguments!(issue_date)

        result = Accounting::Proformas::Update.call(args)

        raise result.error if result.failure?

        result.data
      end
    end
  end
end
