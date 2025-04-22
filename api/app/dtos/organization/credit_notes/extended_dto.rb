module Organization
  module CreditNotes
    class ExtendedDto < Invoices::BaseExtendedDto
      field "status", :enum, subtype: [ "draft", "posted" ]
    end
  end
end
