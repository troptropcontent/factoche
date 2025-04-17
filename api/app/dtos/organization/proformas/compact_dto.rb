module Organization
  module Proformas
    class CompactDto < Invoices::CompactDto
      field "status", :enum, subtype: [ "draft", "posted", "voided" ]
    end
  end
end
