module Organization
  class CreditNote < Organization::AccountingDocument
    has_one :completion_snapshot, class_name: "Organization::CompletionSnapshot", foreign_key: :credit_note_id
  end
end
