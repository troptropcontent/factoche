module Organization
  module Projects
    module Orders
      class CompactDto < BaseCompactDto
        field "invoiced_amount", :decimal
      end
    end
  end
end
