module Organization
  module Quotes
    class CreateContract < Dry::Validation::Contract
      params do
        required(:name).filled(:string)
        optional(:description).maybe(:string)
        required(:retention_guarantee_rate).filled(:decimal)
        required(:items).filled(:array).array(:hash) do
          optional(:group_uuid).maybe(:string)
          required(:name).filled(:string)
          optional(:description).maybe(:string)
          required(:quantity).filled(:integer)
          required(:unit).filled(:string)
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
    end
  end
end
