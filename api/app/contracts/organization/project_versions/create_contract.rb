module Organization
  module ProjectVersions
    class CreateContract < Dry::Validation::Contract
      params do
        required(:retention_guarantee_rate).filled(:decimal)
        required(:groups).type(:array).each do
          schema do
            required(:name).filled(:string)
            optional(:description).filled(:string)
            required(:position).filled(:integer)
            required(:uuid).filled(:string)
          end
        end
        required(:items).filled(:array).each do
          schema do
            required(:name).filled(:string)
            optional(:description).filled(:string)
            optional(:original_item_uuid).filled(:string)
            required(:position).filled(:integer)
            required(:quantity).filled(:integer)
            required(:unit).filled(:string)
            required(:unit_price_amount).filled(:decimal)
            required(:tax_rate).filled(:decimal)
            optional(:group_uuid).filled(:string)
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
    end
  end
end
