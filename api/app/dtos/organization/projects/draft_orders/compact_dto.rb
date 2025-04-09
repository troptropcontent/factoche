module Organization
  module Projects
    module DraftOrders
      class CompactDto < BaseCompactDto
        field "posted", :boolean, required: false
        field "posted_at", :timestamp, required: false
      end
    end
  end
end
