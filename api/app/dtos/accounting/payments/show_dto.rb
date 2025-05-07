module Accounting
  module Payments
    class ShowDto < OpenApiDto
      field "result", :object, subtype: ExtendedDto
    end
  end
end
