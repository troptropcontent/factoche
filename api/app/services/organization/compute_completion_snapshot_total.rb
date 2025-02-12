module Organization
  class ComputeCompletionSnapshotTotal
    class << self
      def call(completion_snapshot)
        project_version_items, completion_snapshot_items = load_dependencies!(completion_snapshot)
        compute_total(project_version_items, completion_snapshot_items)
      end

      private

      def compute_total(project_version_items, completion_snapshot_items)
        indexed_snapshot_items = T.let(
          completion_snapshot_items.index_by(&:item_id),
          T::Hash[Integer, Organization::CompletionSnapshotItem]
        )

        project_version_items.reduce(BigDecimal("0")) do |memo, item|
          completion_percentage = indexed_snapshot_items[item.id]&.completion_percentage || BigDecimal("0")
          current_item_completion_amount = item.quantity * item.unit_price_cents / 100 * completion_percentage
          memo + current_item_completion_amount
        end
      end

      def load_dependencies!(completion_snapshot)
        project_version = completion_snapshot.project_version
        raise Error::UnprocessableEntityError.new("Project version is not defined") if project_version.nil?

        [ project_version.items, completion_snapshot.completion_snapshot_items ]
      end
    end
  end
end
