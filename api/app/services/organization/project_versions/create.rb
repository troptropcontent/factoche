module Organization
  module ProjectVersions
    class Create
      include ApplicationService

      def call(project, params)
        @project = project
        @validated_params = validate!(params, CreateContract)
        @items = []
        @groups = []

        ensure_original_item_uuids_belongs_to_project!

        transaction do
          create_version!
          create_items_structure!

          success(version: @version, items: @items, groups: @groups)
        end
      end

      private

      def ensure_original_item_uuids_belongs_to_project!
        valid_original_item_uuids =  Organization::Item.joins(:project_version).where(project_version: { project_id: @project.id }).pluck(:original_item_uuid).uniq
        params_original_item_uuids = @validated_params[:items].filter_map { |i| i[:original_item_uuid] }
        invalid_uuids = params_original_item_uuids - valid_original_item_uuids
        unless invalid_uuids.empty?
          raise Error::UnprocessableEntityError, "The following original_item_uuids are invalid: #{invalid_uuids.join(', ')}"
        end
      end

      def create_version!
        @version = Organization::ProjectVersion.create!(
          project: @project,
          retention_guarantee_rate: @validated_params[:retention_guarantee_rate],
          total_excl_tax_amount: @validated_params[:items].sum { |item| item[:quantity] * item[:unit_price_amount] },
          general_terms_and_conditions: @validated_params[:general_terms_and_conditions]
        )
      end

      def create_items_structure!
        if @validated_params[:groups].present?
          create_groups_with_items!
        else
          create_standalone_items!
        end
      end

      def create_groups_with_items!
        @validated_params[:groups].each do |group_input|
          group = Organization::ItemGroup.create!({
            name: group_input[:name],
            description: group_input[:description],
            position: group_input[:position],
            project_version: @version
          })
          @groups << group

          @validated_params[:items]
            .filter { |item_input| item_input[:group_uuid] == group_input[:uuid] }
            .map do |item_input|
              @items << Organization::Item.create!(
                build_item_attribute_from_input(item_input, @version, group)
                .merge(item_group: group)
              )
            end
        end
      end

      def create_standalone_items!
        @validated_params[:items].map do |item_input|
          @items << Organization::Item.create!(build_item_attribute_from_input(item_input, @version))
        end
      end

      def build_item_attribute_from_input(input, version, group = nil)
        {
          original_item_uuid: input[:original_item_uuid] || SecureRandom.uuid,
          name: input[:name],
          description: input[:description],
          position: input[:position],
          quantity: input[:quantity],
          unit: input[:unit],
          unit_price_amount: input[:unit_price_amount],
          tax_rate: input[:tax_rate],
          project_version: version,
          item_group: group
        }
      end
    end
  end
end
