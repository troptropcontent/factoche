module Organization
  module Proformas
    class CreateContract < Dry::Validation::Contract
      params do
        required(:invoice_amounts).filled(:array).array(:hash) do
          required(:original_item_uuid).filled(:string)
          required(:invoice_amount).filled(:decimal)
        end
      end
    end
  end
end
