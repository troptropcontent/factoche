module Organization
  class BuildInvoiceFromCompletionSnapshot
    class << self
      def call(snapshot, issue_date)
        payload = BuildCompletionSnapshotInvoicePayload.call(snapshot, issue_date)
        Organization::Invoice.new({
            completion_snapshot_id: snapshot.id,
            number: payload.document_info.number,
            issue_date: issue_date,
            delivery_date: issue_date,
            due_date: payload.document_info.due_date,
            total_excl_tax_amount: payload.transaction.total_excl_tax_amount,
            tax_amount: payload.transaction.tax_amount,
            retention_guarantee_amount: payload.transaction.retention_guarantee_amount,
            total_amount: payload.transaction.invoice_total_amount,
            payload: payload
          })
      end
    end
  end
end
