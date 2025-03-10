module Organization
  module Invoices
    module CompletionSnapshots
      class CreateContract < Dry::Validation::Contract
        params do
          required(:invoice_amounts).array(:hash) do
            required(:original_item_uuid).filled(:string)
            required(:invoice_amount).filled(:decimal)
          end
        end
      end
    end
  end
end
