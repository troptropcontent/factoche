module Organization
  module Projects
    class ShowDto < OpenApiDto
      field "result", :object, subtype: ExtendedDto
    end
  end
end
