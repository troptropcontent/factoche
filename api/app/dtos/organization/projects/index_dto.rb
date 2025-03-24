module Organization
  module Projects
    class IndexDto < OpenApiDto
      field "results", :array, subtype: CompactDto
    end
  end
end
