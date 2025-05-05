module Organization
  module CreditNotes
    class ShowDto < OpenApiDto
      field "result", :object, subtype: ExtendedDto
    end
  end
end
