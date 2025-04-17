module Organization
  module Proformas
    class IndexDto < Invoices::IndexDto
      field "results", :array, subtype: CompactDto
    end
  end
end
