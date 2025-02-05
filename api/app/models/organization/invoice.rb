module Organization
  class Invoice < Organization::AccountingDocument
    has_one :completion_snapshot, class_name: "Organization::CompletionSnapshot", foreign_key: :invoice_id
  end
end
