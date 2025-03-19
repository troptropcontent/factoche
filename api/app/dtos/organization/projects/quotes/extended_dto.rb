module Organization
  module Projects
    module Quotes
      class ExtendedDto < BaseExtendedDto
        field "status", :enum, subtype: [ "draft", "validated" ]
      end
    end
  end
end
