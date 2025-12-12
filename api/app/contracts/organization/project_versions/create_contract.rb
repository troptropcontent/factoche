module Organization
  module ProjectVersions
    class CreateContract < Dry::Validation::Contract
      params do
        required(:retention_guarantee_rate).filled(:decimal)
        required(:general_terms_and_conditions).type(:string)
        required(:groups).type(:array).each do
          schema do
            required(:name).filled(:string)
            optional(:description).type(:string)
            required(:position).filled(:integer)
            required(:uuid).filled(:string)
          end
        end
        required(:items).filled(:array).each do
          schema do
            required(:name).filled(:string)
            optional(:description).type(:string)
            optional(:original_item_uuid).filled(:string)
            required(:position).filled(:integer)
            required(:quantity).filled(:integer)
            required(:unit).filled(:string)
            required(:unit_price_amount).filled(:decimal)
            required(:tax_rate).filled(:decimal)
            optional(:group_uuid).filled(:string)
          end
        end
        optional(:discounts).array do
          schema do
            required(:kind).filled(:string, included_in?: %w[percentage fixed_amount])
            required(:value).filled(:decimal)
            required(:position).filled(:integer)
            required(:name).type(:string)
            optional(:original_discount_uuid).filled(:string)
          end
        end
      end
      rule(:items).each do
        group_uuid = value[:group_uuid]
        next unless group_uuid.present?

        groups = values[:groups] || []
        unless groups.find { |g| g[:uuid] ===  group_uuid }
          key([ key.path.first, key.path.last, :group_uuid ])
            .failure("references a group that doesn't exist in the provided groups list")
        end
      end

      rule(:groups).each do
        group_uuid = value[:uuid]
        items = values[:items]
        unless items.find { |item| item[:group_uuid] == group_uuid }
          key([ key.path.first, key.path.last, :uuid ])
            .failure("is not used by any items - each group must contain at least one item")
        end
      end

      rule(:discounts, :items) do
        # Skip validation if no discounts provided
        next if values[:discounts].blank?

        # Calculate items total
        items_total = values[:items].sum { |item| item[:quantity] * item[:unit_price_amount] }

        # Apply discounts sequentially
        total_after_discounts = values[:discounts].reduce(items_total) do |acc, discount|
          discount_amount = if discount[:kind] == "percentage"
            discount[:value] * acc
          else
            discount[:value]
          end
          acc - discount_amount
        end

        # Fail if total becomes negative
        if total_after_discounts < 0
          key(:discounts).failure(
            "would result in a negative total (#{total_after_discounts.round(2)}€). " \
            "Please reduce discount amounts."
          )
        end
      end
    end
  end
end
