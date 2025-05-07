module Organization
  module Proformas
    class CompactDto < Invoices::BaseCompactDto
      field "status", :enum, subtype: [ "draft", "posted", "voided" ]
    end
  end
end
