module Organization
  class CreateCompletionSnapshot
    class << self
      def call(create_completion_snapshot_dto, project_id)
        project = Organization::Project.find(project_id)
        version = project.last_version

        ensure_no_existing_draft!(project)

        ensure_item_ids_belong_to_project!(version, create_completion_snapshot_dto)

        Organization::CompletionSnapshot.create!({
          description: create_completion_snapshot_dto.description,
          project_version: version,
          completion_snapshot_items_attributes: create_completion_snapshot_dto.completion_snapshot_items.map { |item| {
            completion_percentage: item.completion_percentage,
            item_id: item.item_id
          }}
        })
      end

      private

      def ensure_no_existing_draft!(project)
        if project.completion_snapshots.draft.exists?
          raise Error::UnprocessableEntityError, "A draft already exists for this project. Only one draft can exists for a project at a time."
        end
      end

      def ensure_item_ids_belong_to_project!(version, create_completion_snapshot_dto)
        item_ids = create_completion_snapshot_dto.completion_snapshot_items.map(&:item_id)
        missing_item_ids = item_ids - version.items.pluck(:id)

        if missing_item_ids.any?
          raise Error::UnprocessableEntityError, "The following item IDs do not belong to this project's last version: #{missing_item_ids.join(', ')}"
        end
      end
    end
  end
end
