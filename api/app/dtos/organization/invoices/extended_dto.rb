module Organization
  module Invoices
    class ExtendedDto < OpenApiDto
      class Line < OpenApiDto
        field "holder_id", :string
        field "excl_tax_amount", :decimal
      end

      field "id", :integer
      field "status", :enum, subtype: [ "draft", "posted", "cancelled" ]
      field "number", :string, required: false
      field "updated_at", :timestamp
      field "lines", :array, subtype: Line
    end
  end
end
