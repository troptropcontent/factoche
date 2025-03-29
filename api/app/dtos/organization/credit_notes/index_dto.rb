module Organization
  module CreditNotes
    class IndexDto < OpenApiDto
      field "results", :array, subtype: CompactDto
    end
  end
end
