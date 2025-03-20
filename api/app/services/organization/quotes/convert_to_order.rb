module Organization
  module Quotes
    class ConvertToOrder
      class << self
        def call(quote_version_id)
          quote_version = ProjectVersion.find_by(id: quote_version_id)
          return ServiceResult.failure("Quote version not found") unless quote_version

          quote = quote_version.project
          return ServiceResult.failure("Project is not a quote") unless quote.is_a?(Quote)

          ActiveRecord::Base.transaction do
            order = create_order!(quote, quote_version)
            order_version = create_order_version!(order, quote_version)
            copy_groups_and_items!(quote_version, order_version)

            ServiceResult.success(order)
          end
        rescue StandardError => e
          ServiceResult.failure("Failed to convert quote to order: #{e.message}")
        end

        private

        def create_order!(quote, quote_version)
          Order.create!(
            quote.attributes.except(
              "id", "type", "created_at", "updated_at", "original_quote_version_id"
            ).merge(original_quote_version: quote_version, number: find_next_order_number!(quote.company_id))
          )
        end

        def create_order_version!(order, quote_version)
          ProjectVersion.create!(
            quote_version.attributes.except(
              "id", "project_id", "created_at", "updated_at"
            ).merge(project: order)
          )
        end

        def create_group!(source_group, target_version)
          ItemGroup.create!(
            source_group.attributes.except(
              "id", "project_version_id", "created_at", "updated_at"
            ).merge(project_version: target_version)
          )
        end

        def create_item!(source_item, target_version, target_group = nil)
          Item.create!(
            source_item.attributes.except(
              "id", "project_version_id", "item_group_id", "created_at", "updated_at"
            ).merge(
              project_version: target_version,
              item_group: target_group
            )
          )
        end

        def copy_groups_and_items!(source_version, target_version)
          source_version.item_groups.order(:position).each do |source_group|
            target_group = create_group!(source_group, target_version)
            copy_items!(source_group, target_group, target_version)
          end

          copy_standalone_items!(source_version, target_version) if source_version.items.where(item_group_id: nil).exists?
        end

        def copy_items!(source_group, target_group, target_version)
          source_group.grouped_items.order(:position).each do |source_item|
            create_item!(source_item, target_version, target_group)
          end
        end

        def copy_standalone_items!(source_version, target_version)
          source_version.items.where(item_group_id: nil).order(:position).each do |source_item|
            create_item!(source_item, target_version)
          end
        end

        def find_next_order_number!(company_id)
          r = Projects::FindNextNumber.call(company_id, Quote)
          raise r.error if r.failure?

          r.data
        end
      end
    end
  end
end
