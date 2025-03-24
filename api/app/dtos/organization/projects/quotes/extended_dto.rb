module Organization
  module Projects
    module Quotes
      class ExtendedDto < BaseExtendedDto
        field "status", :enum, subtype: [ "draft", "validated" ]
        field "orders", :array, subtype: Orders::ExtendedDto
      end
    end
  end
end
