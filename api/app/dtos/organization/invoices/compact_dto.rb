module Organization
  module Invoices
    class CompactDto < OpenApiDto
      class Line < OpenApiDto
        field "holder_id", :string
        field "excl_tax_amount", :decimal
      end

      field "holder_id", :integer
      field "id", :integer
      field "status", :enum, subtype: [ "draft", "posted", "cancelled", "voided" ]
      field "number", :string, required: false
      field "issue_date", :timestamp
      field "updated_at", :timestamp
      field "total_amount", :decimal
      field "lines", :array, subtype: Line
      field "pdf_url", :string, required: false
    end
  end
end
