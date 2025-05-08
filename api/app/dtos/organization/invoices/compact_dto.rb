module Organization
  module Invoices
    class CompactDto < BaseCompactDto
      field "payment_status", :enum, subtype: [ "paid", "pending", "overdue" ]
    end
  end
end
