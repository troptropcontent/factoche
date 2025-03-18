module Organization
  module Projects
    module Orders
      class ExtendedDto < BaseExtendedDto
        field "invoiced_amount", :decimal
      end
    end
  end
end
