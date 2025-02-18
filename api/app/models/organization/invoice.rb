module Organization
  class Invoice < Organization::AccountingDocument
    has_one :completion_snapshot, class_name: "Organization::CompletionSnapshot", foreign_key: :invoice_id

    def rebuild_payload
      raise Error::UnprocessableEntityError.new("Can only rebuild payload in development environment") unless Rails.env.development?
      self.update(payload: BuildCompletionSnapshotInvoicePayload.call(completion_snapshot, issue_date))
    end
  end
end
