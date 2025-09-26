module Organization
  module Proformas
    class UpdateContract < Dry::Validation::Contract
      params do
        optional(:issue_date).value(:date)
        required(:invoice_amounts).filled(:array).array(:hash) do
          required(:original_item_uuid).filled(:string)
          required(:invoice_amount).filled(:decimal)
        end
      end
    end
  end
end
