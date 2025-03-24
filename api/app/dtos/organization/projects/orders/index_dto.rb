module Organization
  module Projects
    module Orders
      class IndexDto < OpenApiDto
        field "results", :array, subtype: CompactDto
      end
    end
  end
end
