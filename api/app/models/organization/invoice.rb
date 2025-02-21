module Organization
  class Invoice < Organization::AccountingDocument
    def rebuild_payload
      raise Error::UnprocessableEntityError.new("Can only rebuild payload in development environment") unless Rails.env.development?
      self.update(payload: BuildCompletionSnapshotInvoicePayload.call(completion_snapshot, issue_date))
    end
  end
end
