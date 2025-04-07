module Organization
  module Projects
    class Duplicate
      include ApplicationService

      # Duplicates a project record.
      #
      # @param original_record [Quote, DraftOrder, Order] The original project record to duplicate.
      #
      # @param new_record_class [Class] The class of the new project record to create (Quote, DraftOrder, or Order).
      #
      # @return [Quote, DraftOrder, Order] The newly created project record.
      #
      # @example Duplicating a Quote
      #   original_quote = Quote.find(1)
      #   new_quote = Organization::Projects::Duplicate.call(original_quote, Quote)
      def call(original_record, new_record_class)
        @original_project = original_record

        @original_project_version = @original_project.last_version

        raise "Original project has no version recorded, it's likely a bug" unless @original_project_version

        raise "The new project class must be a descendant of Project" unless new_record_class.superclass == Project

        ActiveRecord::Base.transaction do
          create_new_project!(new_record_class)
          create_new_project_version!
          copy_groups_and_items!

          @new_project
        end
      end

      private

      def create_new_project!(new_project_class)
        @new_project = new_project_class.create!(
            @original_project.attributes.except(
              "id", "type", "created_at", "updated_at", "original_project_version_id"
            ).merge(
              original_project_version: @original_project_version,
              number: find_next_project_number!(new_project_class)
            )
        )
      end

      def find_next_project_number!(new_project_class)
        r = FindNextNumber.call(@original_project.company_id, new_project_class)
        raise r.error if r.failure?

        r.data
      end

      def create_new_project_version!
        @new_project_version = ProjectVersion.create!(
            @original_project_version.attributes.except(
              "id", "project_id", "created_at", "updated_at"
            ).merge(project: @new_project)
          )
      end

      def copy_groups_and_items!
        @original_project_version.item_groups.order(:position).each do |original_project_group|
          new_group = copy_group!(original_project_group)
          copy_items!(original_project_group, new_group)
        end

        copy_standalone_items! if @original_project_version.items.where(item_group_id: nil).exists?
      end

      def copy_group!(original_project_group)
        ItemGroup.create!(
          original_project_group.attributes.except(
              "id", "project_version_id", "created_at", "updated_at"
            ).merge(project_version: @new_project_version)
        )
      end

      def copy_items!(original_project_group, new_group)
        original_project_group.grouped_items.order(:position).each do |original_item|
          copy_item!(original_item, new_group)
        end
      end

      def copy_item!(original_item, new_group = nil)
        # We do not pass the original_item_uuid along here because this is used for invoicing so we prefer not to pass
        # If we later need this to be passed accross projects we will pass it along but we need to ensure that the invoicing it done well (it should actually already work but need to ensure this)
        Item.create!(
          original_item.attributes.except(
            "id", "project_version_id", "item_group_id", "created_at", "updated_at", "original_item_uuid"
          ).merge(
            project_version: @new_project_version,
            item_group: new_group,
            original_item_uuid: SecureRandom.uuid
          )
        )
      end

      def copy_standalone_items!
        @original_project_version.items.where(item_group_id: nil).order(:position).each do |original_item|
          copy_item!(original_item)
        end
      end
    end
  end
end
