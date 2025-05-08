module Organization
  module Invoices
    class ExtendedDto < BaseExtendedDto
      field "credit_note", :object, subtype: BaseExtendedDto, required: false
      field "payment_status", :enum, subtype: [ "paid", "overdue", "pending" ]
    end
  end
end
