module Organization
  module Projects
    class UpdateContract < Dry::Validation::Contract
      params do
        required(:name).filled(:string)
        optional(:description).maybe(:string)
        required(:bank_detail_id).filled(:integer)
        required(:retention_guarantee_rate).filled(:decimal)
        required(:new_items).array(:hash) do
          optional(:group_uuid).maybe(:string)
          required(:name).filled(:string)
          optional(:description).maybe(:string)
          required(:quantity).filled(:integer)
          required(:unit).filled(:string)
          required(:unit_price_amount).filled(:decimal)
          required(:position).filled(:integer)
          required(:tax_rate).filled(:decimal)
        end
        required(:updated_items).array(:hash) do
          optional(:group_uuid).maybe(:string)
          required(:original_item_uuid).filled(:string)
          required(:quantity).filled(:integer)
          required(:unit_price_amount).filled(:decimal)
          required(:position).filled(:integer)
          required(:tax_rate).filled(:decimal)
        end
        required(:groups).array(:hash) do
          required(:uuid).filled(:string)
          required(:name).filled(:string)
          optional(:description).maybe(:string)
          required(:position).filled(:integer)
        end
      end

      rule(:new_items, :updated_items).each do
        group_uuid = value[:group_uuid]
        next unless group_uuid.present?

        groups = values[:groups] || []
        unless groups.map { |g| g[:uuid] }.include?(group_uuid)
          key([ key.path.first, key.path.last, :group_uuid ])
            .failure("references a group that doesn't exist in the provided groups list")
        end
      end

      rule(:groups).each do
        group_uuid = value[:uuid]
        items = values[:new_items] + values[:updated_items]
        unless items.find { |item| item[:group_uuid] == group_uuid }
          key([ key.path.first, key.path.last, :uuid ])
            .failure("is not used by any items - each group must contain at least one item")
        end
      end
    end
  end
end
