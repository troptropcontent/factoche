module Organization
  module Invoices
    class CompactDto < OpenApiDto
      class Line < OpenApiDto
        field "holder_id", :string
        field "excl_tax_amount", :decimal
      end

      field "id", :integer
      field "status", :enum, subtype: [ "draft", "posted", "cancelled", "voided" ]
      field "number", :string, required: false
      field "updated_at", :timestamp
      field "total_amount", :decimal
      field "lines", :array, subtype: Line
    end
  end
end
