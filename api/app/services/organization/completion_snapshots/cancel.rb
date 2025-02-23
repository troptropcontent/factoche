module Organization
  module CompletionSnapshots
    class Cancel
      class << self
        def call(snapshot)
          ensure_snapshot_is_published!(snapshot)
          credit_note = nil
          ActiveRecord::Base.transaction do
            snapshot.invoice.update!({ status: :cancelled })
            credit_note = CreditNotes::BuildCreditNoteFromInvoice.call(snapshot.invoice)
            credit_note.status = :published
            credit_note.save!
          end
          # Trigger the generation of the credit_note here
          ServiceResult.success(credit_note)
        rescue StandardError => e
          ServiceResult.failure(e)
        end

        private

        def ensure_snapshot_is_published!(snapshot)
          return if snapshot.status == "published"

          raise Error::UnprocessableEntityError, "Cannot cancel a completion snapshot that is not published, current snapshot status is #{snapshot.status}"
        end
      end
    end
  end
end
