module Organization
  module CompletionSnapshots
    class Cancel
      class << self
        def call(snapshot)
          ensure_snapshot_is_published!(snapshot)

          ActiveRecord::Base.transaction do
            snapshot.invoice.update!({ status: :cancelled })
            credit_note = CreditNotes::BuildCreditNoteFromInvoice.call(snapshot.invoice)
            credit_note.save!

            ServiceResult.success(credit_note)
          end
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
