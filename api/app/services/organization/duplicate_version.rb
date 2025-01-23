module Organization
  class DuplicateVersion
    COLUMNS = [ :name, :description, :quantity, :unit, :unit_price_cents, :position ].freeze

    class << self
      def call(initial_project_version)
        ActiveRecord::Base.transaction do
          new_project_version = duplicate_version!(initial_project_version)
          duplicate_items!(initial_project_version, new_project_version)
          duplicate_item_groups!(initial_project_version, new_project_version)
        end
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error("DuplicateVersion failed: #{e.message}")
        raise
      end

      private

      def duplicate_version!(initial_version)
        initial_version.project.versions.create!(
          retention_guarantee_rate: initial_version.retention_guarantee_rate
        )
      end

      def duplicate_items!(initial_version, new_version)
        create_params = build_items_params(initial_version.ungrouped_items)
        new_version.ungrouped_items.create!(create_params)
      end

      def duplicate_item_groups!(initial_version, new_version)
        initial_version.item_groups.find_each do |item_group|
          new_version.item_groups.create!(
            name: item_group.name,
            description: item_group.description,
            position: item_group.position,
            grouped_items_attributes: build_items_params(item_group.grouped_items, new_version.id)
          )
        end
      end

      def build_items_params(items, project_version_id = nil)
        items.pluck(*COLUMNS).map do |data|
          params = COLUMNS.zip(data).to_h
          project_version_id ? params.merge(project_version_id: project_version_id) : params
        end
      end
    end
  end
end
