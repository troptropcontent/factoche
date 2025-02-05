module Organization
  class DestroyCompletionSnapshot
    class << self
      def call(completion_snapshot)
        ensure_draft!(completion_snapshot)

        completion_snapshot.destroy!
      end

      private

      def ensure_draft!(completion_snapshot)
        if completion_snapshot.status != "draft"
          raise Error::UnprocessableEntityError,
            "Cannot delete completion snapshot with status '#{completion_snapshot.status}'. Only snapshots in 'draft' status can be deleted"
        end
      end
    end
  end
end
