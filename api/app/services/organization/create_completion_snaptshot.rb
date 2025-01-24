module Organization
  class CreateCompletionSnapshot
    class << self
      def call(create_completion_snapshot_dto, project_id)
        check

        create_new_snapshot_on_last_version!
      end

      private

      def create_new_snapshot_on_last_version!(create_completion_snapshot_dto, project_id)
        project = Organization::Project.find(project_id)
        version = project.last_version
        Organization::CompletionSnapshot.create({
          description: create_completion_snapshot_dto.description,
          project_version: version.id,
          completion_snapshot_items_attributes: create_completion_snapshot_dto.completion_snapshot_items.map { |item| {
            completion_percentage: item.completion_percentage,
            item_id: item.item_id
          }}
        })
      end
    end
  end
end
