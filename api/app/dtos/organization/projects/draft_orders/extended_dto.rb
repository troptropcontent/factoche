module Organization
  module Projects
    module DraftOrders
      class ExtendedDto < BaseExtendedDto
        field "original_project_version_id", :integer
        field "posted", :boolean
        field "posted_at", :timestamp, required: false
      end
    end
  end
end
