module Organization
  module Projects
    module Orders
      class ExtendedDto < BaseExtendedDto
        field "original_quote_version_id", :integer
        field "invoiced_amount", :decimal
      end
    end
  end
end
