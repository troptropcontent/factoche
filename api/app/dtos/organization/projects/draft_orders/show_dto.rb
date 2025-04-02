module Organization
  module Projects
    module DraftOrders
      class ShowDto < OpenApiDto
        field "result", :object, subtype: ExtendedDto
      end
    end
  end
end
