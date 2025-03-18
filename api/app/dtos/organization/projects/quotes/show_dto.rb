module Organization
  module Projects
    module Quotes
      class ShowDto < OpenApiDto
        field "result", :object, subtype: ExtendedDto
      end
    end
  end
end
