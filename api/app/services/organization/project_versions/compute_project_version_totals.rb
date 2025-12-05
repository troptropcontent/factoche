# frozen_string_literal: true

module Organization
  module ProjectVersions
    class ComputeProjectVersionTotals
      include ApplicationService

      def call(project_version)
        validate_project_version!(project_version)

        items = project_version.items.to_a
        discounts = project_version.discounts.ordered.to_a

        # Calculate subtotal
        subtotal = calculate_subtotal(items)

        # Calculate total discount (applied sequentially)
        total_discount = calculate_total_discount(discounts, subtotal)

        # Calculate tax and total including tax
        total_tax, total_incl_tax = calculate_tax_and_total(items, subtotal, total_discount)

        {
          subtotal: subtotal.round(2),
          total_discount: total_discount.round(2),
          total_tax: total_tax.round(2),
          total_incl_tax: total_incl_tax.round(2)
        }
      end

      private

      def validate_project_version!(project_version)
        if project_version.nil?
          raise Error::UnprocessableEntityError.new(
            message: "project_version cannot be nil"
          )
        end
      end

      def calculate_subtotal(items)
        items.sum do |item|
          item.quantity.to_d * item.unit_price_amount.to_d
        end
      end

      def calculate_total_discount(discounts, subtotal)
        running_total = subtotal
        total_discount = 0.to_d

        discounts.each do |discount|
          discount_amount = discount.amount.to_d
          total_discount += discount_amount
          running_total -= discount_amount
        end

        total_discount
      end

      def calculate_tax_and_total(items, subtotal, total_discount)
        # If no items or discount exceeds subtotal, return zeros
        if items.empty? || subtotal.zero? || total_discount >= subtotal
          return [ 0.to_d, 0.to_d ]
        end

        total_tax = 0.to_d
        total_incl_tax = 0.to_d

        items.each do |item|
          item_subtotal = item.quantity.to_d * item.unit_price_amount.to_d

          # Calculate this item's proportional share of the total discount
          proportion = item_subtotal / subtotal
          item_discount = (total_discount * proportion).round(2)

          # Calculate item amount after discount
          item_after_discount = item_subtotal - item_discount

          # Calculate tax on discounted amount
          item_tax = (item_after_discount * item.tax_rate.to_d).round(2)
          item_total = item_after_discount + item_tax

          total_tax += item_tax
          total_incl_tax += item_total
        end

        [ total_tax, total_incl_tax ]
      end
    end
  end
end
