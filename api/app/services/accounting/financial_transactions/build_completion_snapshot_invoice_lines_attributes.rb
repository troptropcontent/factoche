module Accounting
  module FinancialTransactions
    class BuildCompletionSnapshotInvoiceLinesAttributes
      class << self
        def call(invoice_context, new_invoice_items)
          attributes = invoice_context.fetch("project_version_items").map do |project_version_item|
            invoice_amount = find_invoice_amount_for_item(new_invoice_items, project_version_item)

            ensure_total_invoiced_amount_remains_within_limits!(invoice_amount, project_version_item)

            # Calculate the proportional quantity based on invoice amount divided by unit price
            # e.g. if invoicing 125€ for an item with unit price 100€, quantity will be 1.25
            quantity = invoice_amount / project_version_item.fetch("unit_price_amount").to_d



            {
              holder_id: project_version_item.fetch("original_item_uuid"),
              quantity: quantity,
              unit: project_version_item.fetch("unit"),
              unit_price_amount: project_version_item.fetch("unit_price_amount").to_d,
              excl_tax_amount: invoice_amount,
              tax_rate: project_version_item.fetch("tax_rate").to_d,
              group_id: project_version_item.fetch("group_id")
            }
          end

          ServiceResult.success(attributes)
        rescue StandardError => e
          ServiceResult.failure("Failed to build invoice line attributes for invoice_context: #{invoice_context}, " \
                              "new_invoice_items: #{new_invoice_items}. " \
                              "Error: #{e.message}")
        end

        private

        def find_invoice_amount_for_item(new_invoice_items, project_version_item)
          new_invoice_items.find { |new_invoice_item| new_invoice_item.fetch(:original_item_uuid) === project_version_item.fetch("original_item_uuid") }&.fetch(:invoice_amount)&.to_d || BigDecimal("0")
        end

        # Ensures that the total invoiced amount (previously invoiced + current invoice amount)
        # does not exceed the maximum allowed amount for a project version item.
        # The maximum allowed amount is calculated by multiplying the unit price by the quantity.
        #
        # @param invoice_amount [BigDecimal] The amount being invoiced in the current invoice
        # @param project_version_item [Hash] The project version item containing unit price, quantity and previously invoiced amount
        # @raise [StandardError] If the total invoiced amount would exceed the maximum allowed amount
        def ensure_total_invoiced_amount_remains_within_limits!(invoice_amount, project_version_item)
          total_amount = project_version_item.fetch("unit_price_amount").to_d * project_version_item.fetch("quantity").to_d
          previously_invoiced = project_version_item.fetch("previously_invoiced_amount", 0).to_d

          return if (previously_invoiced + invoice_amount) <= total_amount

          raise StandardError, "Total invoiced amount (#{previously_invoiced + invoice_amount}) would exceed the maximum allowed amount (#{total_amount}) for item #{project_version_item.fetch('original_item_uuid')}"
        end
      end
    end
  end
end
