module Organization
  module Projects
    module Orders
      class ShowDto < OpenApiDto
        field "result", :object, subtype: ExtendedDto
      end
    end
  end
end
