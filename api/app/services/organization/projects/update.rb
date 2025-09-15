module Organization
  module Projects
    class Update
      include ApplicationService

      def call(project, params)
        @project = project
        @project_items = fetch_project_items

        validated_params = validate!(params, UpdateContract)
        ensure_original_item_uuids_exist!(validated_params)

        transaction do
          @project.update!(validated_params.slice(:name, :description))
          version = create_new_version!(validated_params)

          { project: @project, version: version }
        end
      end

      private

      def fetch_project_items
        Organization::Item
          .joins(:project_version)
          .where(project_version: { project_id: @project.id })
          .to_a
      end

      def ensure_original_item_uuids_exist!(params)
        valid_uuids = @project_items.map(&:original_item_uuid).uniq
        invalid_uuids = params[:updated_items]
          .map { |i| i[:original_item_uuid] }
          .reject { |uuid| valid_uuids.include?(uuid) }

        return if invalid_uuids.empty?

        raise Error::UnprocessableEntityError,
          "The following original_item_uuids are invalid: #{invalid_uuids.join(', ')}"
      end

      def fetch_original_item(uuid)
        @project_items.find { |item| item.original_item_uuid == uuid }
      end

      def create_new_version!(validated_params)
        mapped_params = map_params(validated_params)
        result = ProjectVersions::Create.call(@project, mapped_params)

        unless result.success?
          raise Error::UnprocessableEntityError.new(
            "Failed to create project version: #{result.error}"
          )
        end

        result.data[:version]
      end

      def map_params(validated_params)
        {
          retention_guarantee_rate: validated_params[:retention_guarantee_rate],
          bank_detail_id: validated_params[:bank_detail_id],
          items: combine_items(validated_params),
          groups: validated_params[:groups]
        }
      end

      def combine_items(params)
        new_items = params[:new_items] || []
        updated_items = map_updated_items(params[:updated_items] || [])

        new_items + updated_items
      end

      def map_updated_items(updated_items_params)
        updated_items_params.map do |updated_item_param|
          original_item = fetch_original_item(updated_item_param[:original_item_uuid])
          original_item_attributes = {
            name: original_item.name,
            description: original_item.description,
            unit: original_item.unit
          }.compact
          updated_item_param.merge(
            original_item_attributes
          )
        end
      end
    end
  end
end
