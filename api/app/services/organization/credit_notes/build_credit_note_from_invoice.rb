module Organization
  module CreditNotes
    class BuildCreditNoteFromInvoice
      class << self
        def call(invoice, issue_date = Time.current)
          payload = BuildPayloadFromInvoice.call(invoice, issue_date)

          CreditNote.new(
            original_invoice_id: invoice.id,
            issue_date: payload.document_info.issue_date,
            number: payload.document_info.number,
            tax_amount: payload.transaction.tax_amount,
            retention_guarantee_amount: payload.transaction.retention_guarantee_amount,
            payload: payload,
            total_excl_tax_amount: payload.transaction.total_excl_tax_amount,
            total_amount: payload.transaction.credit_note_total_amount,
            status: "draft"
          )
        end
      end
    end
  end
end
