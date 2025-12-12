module Accounting
  ProjectVersionSchema = Dry::Schema.Params do
    required(:id).filled(:integer)
    required(:number).filled(:integer)
    required(:created_at).filled(:time)
    required(:retention_guarantee_rate).filled(:decimal)
    required(:items).array(:hash) do
      required(:original_item_uuid).filled(:string)
      required(:group_id).maybe(:integer)
      required(:name).filled(:string)
      required(:description).maybe(:string)
      required(:quantity).filled(:integer)
      required(:unit).filled(:string)
      required(:unit_price_amount).filled(:decimal)
      required(:tax_rate).filled(:decimal)
    end
    required(:item_groups).array(:hash) do
      required(:id).filled(:integer)
      required(:name).filled(:string)
      required(:description).maybe(:string)
    end
    optional(:discounts).array(:hash) do
      required(:original_discount_uuid).filled(:string)
      required(:kind).filled(:string)
      required(:value).filled(:decimal)
      required(:amount).filled(:decimal)
      required(:position).filled(:integer)
      optional(:name).maybe(:string)
    end
  end
end
