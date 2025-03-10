module Organization
  module Invoices
    module CompletionSnapshots
      class CreateDto < OpenApiDto
        class InvoiceAmount < OpenApiDto
          field "original_item_uuid", :string
          field "invoice_amount", :decimal
        end
        field "invoice_amounts", :array, subtype: InvoiceAmount
      end
    end
  end
end
