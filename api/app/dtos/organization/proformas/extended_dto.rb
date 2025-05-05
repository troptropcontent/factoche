module Organization
  module Proformas
    class ExtendedDto < Invoices::BaseExtendedDto
      field "status", :enum, subtype: [ "draft", "posted", "voided" ]
    end
  end
end
