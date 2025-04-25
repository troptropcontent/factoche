module Organization
  module Invoices
    class ExtendedDto < BaseExtendedDto
      field "credit_note", :object, subtype: BaseExtendedDto, required: false
    end
  end
end
