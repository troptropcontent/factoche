module Organization
  class TransitionCompletionSnapshotToInvoiced
    class << self
      # Update the associated invoice record for the given completion snapshot to its final stage and set its status to published.
      # Trigger the generation of a PDF
      # @param snapshot [Organization::CompletionSnapshot] The completion snapshot to publish
      # @raise [Error::UnprocessableEntityError] If snapshot is not in draft status
      def call(snapshot, issue_date)
        ensure_snapshot_is_draft!(snapshot)

        ActiveRecord::Base.transaction do
          updated_invoice = update_associated_invoice!(snapshot)

          GenerateAndAttachPdfToInvoiceJob.perform_async({ "completion_snapshot_id"=> snapshot.id })

          [ snapshot, updated_invoice ]
        end
      end

      private

      def ensure_snapshot_is_draft!(snapshot)
        if snapshot.status != "draft"
          raise Error::UnprocessableEntityError, "Only draft completion snapshots can be transitioned to invoiced"
        end
      end

      def update_associated_invoice!(completion_snapshot)
        update_invoice_attributes = BuildInvoiceFromCompletionSnapshot.call(completion_snapshot, Time.current).attributes.except("id", "created_at", "updated_at")

        related_incoice = completion_snapshot.invoice

        related_incoice.update!(**update_invoice_attributes, status: "published")
        related_incoice
      end
    end
  end
end
