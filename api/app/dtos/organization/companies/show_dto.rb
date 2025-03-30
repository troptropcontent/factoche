module Organization
  module Companies
    class ShowDto < OpenApiDto
        field "result", :object, subtype: ExtendedDto
    end
  end
end
