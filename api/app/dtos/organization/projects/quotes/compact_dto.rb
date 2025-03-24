module Organization
  module Projects
    module Quotes
      class CompactDto < BaseCompactDto
        field "status", :enum, subtype: [ "draft", "validated" ]
      end
    end
  end
end
