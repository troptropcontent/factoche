module Organization
  class UpdateCompletionSnapshot
    class << self
      def call(update_dto, completion_snapshot)
        ensure_draft!(completion_snapshot)

        ensure_item_ids_belong_to_project!(completion_snapshot, update_dto)

        ActiveRecord::Base.transaction  do
          delete_previous_completion_snapshot_items!(completion_snapshot)
          updated_compeltion_snapshot = update_completion_snapshot!(completion_snapshot, update_dto)
          update_associated_invoice!(updated_compeltion_snapshot)
          updated_compeltion_snapshot
        end
      end

      private

      def ensure_draft!(completion_snapshot)
        if completion_snapshot.status != "draft"
          raise Error::UnprocessableEntityError,
            "Cannot update completion snapshot with status '#{completion_snapshot.status}'. Only snapshots in 'draft' status can be updated"
        end
      end

      def ensure_item_ids_belong_to_project!(completion_snapshot, update_dto)
        item_ids = update_dto.completion_snapshot_items.map(&:item_id)
        missing_item_ids = item_ids - completion_snapshot.project_version.items.pluck(:id)

        if missing_item_ids.any?
          raise Error::UnprocessableEntityError, "The following item IDs do not belong to this completion snapshot project version: #{missing_item_ids.join(', ')}"
        end
      end

      def delete_previous_completion_snapshot_items!(completion_snapshot)
        completion_snapshot.completion_snapshot_items.destroy_all
      end

      def update_completion_snapshot!(completion_snapshot, update_dto)
        completion_snapshot.update!({
          description: update_dto.description,
          project_version: completion_snapshot.project_version,
          completion_snapshot_items_attributes: update_dto.completion_snapshot_items.map { |item| {
            completion_percentage: item.completion_percentage,
            item_id: item.item_id
          } }
        })

        completion_snapshot
      end

      def update_associated_invoice!(completion_snapshot)
        update_invoice_attributes = BuildInvoiceFromCompletionSnapshot.call(completion_snapshot, Time.current).attributes.except("id", "created_at", "updated_at")

        related_incoice = completion_snapshot.invoice

        related_incoice.update!(**update_invoice_attributes)
        related_incoice
      end
    end
  end
end
