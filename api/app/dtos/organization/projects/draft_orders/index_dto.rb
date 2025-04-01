module Organization
  module Projects
    module DraftOrders
      class IndexDto < OpenApiDto
        field "results", :array, subtype: CompactDto
      end
    end
  end
end
