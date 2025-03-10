module Organization
  module Invoices
    class CompactDto < OpenApiDto
      field "id", :integer
      field "status", :enum, subtype: [ "draft", "posted", "cancelled" ]
      field "number", :string, required: false
      field "updated_at", :timestamp
      field "total_amount", :decimal
    end
  end
end
