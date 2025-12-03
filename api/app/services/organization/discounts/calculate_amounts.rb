module Organization
  module Discounts
    class CalculateAmounts
      include ApplicationService

      class CalculateAmountsContract < Dry::Validation::Contract
        params do
          required(:items_total).filled(:decimal)
          required(:discounts).array(:hash) do
            required(:kind).filled(:string, included_in?: %w[percentage fixed_amount])
            required(:value).filled(:decimal)
            required(:position).filled(:integer)
            optional(:name).maybe(:string)
            optional(:original_discount_uuid).maybe(:string)
          end
        end

        rule(:discounts).each do
          # Validate each discount's value based on its kind
          if key? && value[:kind] == "percentage"
            if value[:value] <= 0 || value[:value] > 1
              key.failure("must be between 0 and 1 for percentage discounts")
            end
          elsif key? && value[:kind] == "fixed_amount"
            if value[:value] <= 0
              key.failure("must be greater than 0 for fixed_amount discounts")
            end
          end

          # Validate positions are positive
          if key? && value[:position] <= 0
            key.failure("position must be greater than 0")
          end
        end
      end

      # Calculates discount amounts sequentially
      # @param args [Hash] { items_total: BigDecimal, discounts: Array<Hash> }
      # @return [Hash] { discounts: [...with amounts...], total_discount: BigDecimal, final_total: BigDecimal }
      def call(args)
        validated_args = validate!(args, CalculateAmountsContract)

        items_total = validated_args[:items_total].to_d
        discounts = validated_args[:discounts]

        # Sort by position
        sorted_discounts = discounts.sort_by { |d| d[:position] }

        # Calculate amounts sequentially
        running_total = items_total
        calculated_discounts = []

        sorted_discounts.each do |discount|
          discount_amount = calculate_discount_amount(discount, running_total)
          running_total -= discount_amount

          merged_discount = discount.merge(
            amount: discount_amount.round(2),
            running_total_after: running_total.round(2)
          )
          calculated_discounts << merged_discount
        end

        {
          discounts: calculated_discounts,
          total_discount: (items_total - running_total).round(2),
          final_total: running_total.round(2)
        }
      end

      private

      def calculate_discount_amount(discount, running_total)
        case discount[:kind]
        when "fixed_amount"
          # Fixed amount cannot exceed running total
          [ discount[:value].to_d, running_total ].min
        when "percentage"
          # Percentage applied to running total
          running_total * discount[:value].to_d
        end
      end
    end
  end
end
