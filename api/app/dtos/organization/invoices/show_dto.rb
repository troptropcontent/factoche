module Organization
  module Invoices
    class ShowDto < OpenApiDto
      field "result", :object, subtype: ExtendedDto
    end
  end
end
