module Accounting
  module Payments
    class ExtendedDto < OpenApiDto
      field "invoice_id", :integer
      field "amount", :decimal
      field "received_at", :timestamp
    end
  end
end
