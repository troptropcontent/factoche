module Organization
  module Proformas
    class ShowDto < OpenApiDto
      field "result", :object, subtype: ExtendedDto
    end
  end
end
