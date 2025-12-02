# frozen_string_literal: true

module Organization
  module Discounts
    class Duplicate
      include ApplicationService

      # Duplicates discounts from one project version to another
      #
      # @param original_project_version [ProjectVersion] The original version with discounts
      # @param new_project_version [ProjectVersion] The new version to copy discounts to
      #
      # @return [ProjectVersion] The new project version with duplicated discounts
      def call(original_project_version:, new_project_version:)
        discounts = original_project_version.discounts.ordered

        return new_project_version if discounts.empty?

        discounts.each do |original_discount|
          new_project_version.discounts.create!(
            original_discount.attributes.except(
              "id", "project_version_id", "created_at", "updated_at"
            )
          )
        end

        new_project_version
      end
    end
  end
end
