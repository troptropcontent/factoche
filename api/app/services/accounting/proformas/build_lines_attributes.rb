module Accounting
  module Proformas
    class BuildLinesAttributes
      include ApplicationService

      def call(invoice_context, invoice_amounts, invoice_discounts = [])
        @invoice_context = invoice_context
        @invoice_amounts = invoice_amounts
        @invoice_discounts = build_discount_map(invoice_discounts)

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

        # Only apply discounts if manual amounts are provided
        # If no manual amounts, return empty array (no automatic proportional calculation)
        return [] if @invoice_discounts.empty?

        # Apply discounts using manual amounts
        discounts.filter_map do |discount|
          discount_uuid = discount.fetch("original_discount_uuid")
          manual_amount = @invoice_discounts[discount_uuid]

          # Skip this discount if no amount provided or amount is zero
          next unless manual_amount && manual_amount.to_d > 0

          # Validate the discount amount doesn't exceed limits
          ensure_total_invoiced_discount_amount_remains_within_limits!(manual_amount, discount)

          {
            holder_id: discount_uuid,
            quantity: 1,
            unit: discount["kind"] === "percentage" ? "%" : "€",
            unit_price_amount: -manual_amount.to_d,
            excl_tax_amount: -manual_amount.to_d,
            tax_rate: 0,
            group_id: nil,
            kind: "discount"
          }
        end
      end

      def build_discount_map(invoice_discounts)
        return {} if invoice_discounts.blank?

        invoice_discounts.each_with_object({}) do |discount, hash|
          uuid = discount.fetch(:original_discount_uuid)
          amount = discount.fetch(:discount_amount)
          hash[uuid] = amount
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

      # Ensures that the total invoiced discount amount (previously invoiced + current discount amount)
      # does not exceed the maximum allowed discount amount for a project version discount.
      # The maximum allowed amount is the absolute value of the discount amount.
      #
      # @param discount_amount [BigDecimal, String, Numeric] The discount amount being applied in the current invoice
      # @param project_version_discount [Hash] The project version discount containing amount and previously billed amount
      # @raise [StandardError] If the total discount amount would exceed the maximum allowed discount
      def ensure_total_invoiced_discount_amount_remains_within_limits!(discount_amount, project_version_discount)
        total_discount = project_version_discount.fetch("amount").to_d.abs
        previously_billed = project_version_discount.fetch("previously_billed_amount", 0).to_d.abs
        discount_amount_decimal = discount_amount.to_d

        # Discount amounts are positive in input, but stored as negative in the system
        # We compare absolute values for clarity
        tolerance = 0.01
        return if (previously_billed + discount_amount_decimal) <= (total_discount + tolerance)

        raise StandardError, "Total discount amount (#{previously_billed + discount_amount_decimal}) would exceed the maximum allowed discount (#{total_discount}) for discount #{project_version_discount.fetch('original_discount_uuid')}"
      end
    end
  end
end
