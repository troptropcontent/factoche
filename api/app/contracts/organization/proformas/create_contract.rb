module Organization
  module Proformas
    class CreateContract < Dry::Validation::Contract
      extend DryValidationOpenapi::Convertable

      params do
        optional(:issue_date).value(:time)
        required(:invoice_amounts).array(:hash) do
          required(:original_item_uuid).filled(:string)
          required(:invoice_amount).filled(:decimal)
        end
      end
    end
  end
end
