module Organization
  module Projects
    module Quotes
      class IndexDto < OpenApiDto
        field "results", :array, subtype: CompactDto
      end
    end
  end
end
