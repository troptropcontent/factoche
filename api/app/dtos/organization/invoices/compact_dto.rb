module Organization
  module Invoices
    class CompactDto < OpenApiDto
      field "holder_id", :integer
      field "id", :integer
      field "status", :enum, subtype: [ "draft", "posted", "cancelled", "voided" ]
      field "number", :string
      field "issue_date", :timestamp
      field "updated_at", :timestamp
      field "total_amount", :decimal
      field "total_excl_tax_amount", :decimal
      field "total_including_tax_amount", :decimal
      field "total_excl_retention_guarantee_amount", :decimal
      field "pdf_url", :string, required: false
    end
  end
end
