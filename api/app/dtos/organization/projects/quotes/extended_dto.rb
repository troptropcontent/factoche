module Organization
  module Projects
    module Quotes
      class ExtendedDto < BaseExtendedDto
        field "posted", :boolean
        field "posted_at", :timestamp, required: false
        field "draft_orders", :array, subtype: DraftOrders::ExtendedDto
      end
    end
  end
end
