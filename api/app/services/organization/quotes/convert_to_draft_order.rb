module Organization
  module Quotes
    class ConvertToDraftOrder
      class << self
        def call(quote_id)
          return ServiceResult.failure("quote_id must be an integer") unless quote_id.is_a?(Integer)
          quote = Quote.find(quote_id)

          quote_version = quote.last_version
          return ServiceResult.failure("Quote have no version recorded, it's likely a bug") unless quote_version

          ensure_quote_have_not_been_converted_already!(quote)

          ActiveRecord::Base.transaction do
            draft_order = create_draft_order!(quote, quote_version)
            draft_order_version = create_draft_order_version!(draft_order, quote_version)
            copy_groups_and_items!(quote_version, draft_order_version)

            quote.update!(posted: true)

            ServiceResult.success(draft_order)
          end
        rescue StandardError => e
          ServiceResult.failure("Failed to convert quote to order: #{e.message}, #{e.backtrace[0]}")
        end

        private

        def create_draft_order!(quote, quote_version)
          DraftOrder.create!(
            quote.attributes.except(
              "id", "type", "created_at", "updated_at", "original_project_version_id"
            ).merge(original_project_version: quote_version, number: find_next_draft_order_number!(quote.company_id))
          )
        end

        def create_draft_order_version!(order, quote_version)
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

        def find_next_draft_order_number!(company_id)
          r = Projects::FindNextNumber.call(company_id, DraftOrder)
          raise r.error if r.failure?

          r.data
        end

        def ensure_quote_have_not_been_converted_already!(quote)
          # quote.posted? should be enought but we never know
          is_converted = quote.posted? || quote.draft_orders.any?
          raise Error::UnprocessableEntityError, "Quote has already been converted to an draft order" if is_converted
        end
      end
    end
  end
end
