module Organization
  module Invoices
    class IndexDto < OpenApiDto
      field "results", :array, subtype: CompactDto
    end
  end
end
