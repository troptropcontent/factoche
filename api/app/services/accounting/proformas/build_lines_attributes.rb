module Accounting
  module Proformas
    class BuildLinesAttributes
      include ApplicationService

      def call(invoice_context, invoice_amounts)
        @invoice_context = invoice_context
        @invoice_amounts = invoice_amounts

        # Build charge lines for items
        charge_lines = build_charge_lines

        # Build discount lines if discounts exist
        discount_lines = build_discount_lines

        charge_lines + discount_lines
      end

      private

      def build_charge_lines
        @invoice_amounts.map do |invoice_amount|
          line_amount = invoice_amount.fetch(:invoice_amount).to_d
          project_version_item = find_project_version_item(invoice_amount.fetch(:original_item_uuid))

          ensure_total_invoiced_amount_remains_within_limits!(line_amount, project_version_item)

          # Calculate the proportional quantity based on invoice amount divided by unit price
          # e.g. if invoicing 125€ for an item with unit price 100€, quantity will be 1.25
          quantity = line_amount / project_version_item.fetch("unit_price_amount").to_d

          {
            holder_id: project_version_item.fetch("original_item_uuid"),
            quantity: quantity,
            unit: project_version_item.fetch("unit"),
            unit_price_amount: project_version_item.fetch("unit_price_amount").to_d,
            excl_tax_amount: line_amount,
            tax_rate: project_version_item.fetch("tax_rate").to_d,
            group_id: project_version_item.fetch("group_id"),
            kind: "charge"
          }
        end
      end

      def build_discount_lines
        discounts = @invoice_context.fetch("project_version_discounts", [])
        return [] if discounts.empty?

        # Calculate the total invoice amount for this proforma
        total_invoice_amount = @invoice_amounts.sum { |invoice_amount| invoice_amount.fetch(:invoice_amount).to_d }

        # Calculate the total project amount
        total_project_amount = @invoice_context.fetch("project_total_amount").to_d

        # Calculate the proportion of the project being invoiced
        invoice_proportion = total_invoice_amount / total_project_amount

        # Apply discounts proportionally
        discounts.map do |discount|
          discount_amount = discount.fetch("amount").to_d
          proportional_discount_amount = (discount_amount * invoice_proportion).round(2)

          {
            holder_id: discount.fetch("original_discount_uuid"),
            quantity: 1,
            unit: discount["kind"] === "percentage" ? "%" : "€",
            unit_price_amount: -proportional_discount_amount,
            excl_tax_amount: -proportional_discount_amount,
            tax_rate: 0,
            group_id: nil,
            kind: "discount"
          }
        end
      end

      def find_project_version_item(original_item_uuid)
        @invoice_context.fetch("project_version_items").find { |project_version_item| project_version_item.fetch("original_item_uuid") == original_item_uuid }
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
