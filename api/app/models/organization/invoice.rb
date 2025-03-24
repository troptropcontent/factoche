module Organization
  class Invoice < ActiveRecord::Base
    include PdfAttachable

    belongs_to :completion_snapshot, class_name: "Organization::CompletionSnapshot"
    has_one_attached :xml

    has_one :credit_note, class_name: "Organization::CreditNote", foreign_key: :original_invoice_id, dependent: :destroy

    validates :total_excl_tax_amount, numericality: { greater_than_or_equal_to: 0 }

    enum :status, {
      draft: "draft",
      published: "published",
      cancelled: "cancelled"
    }, default: :draft, validate: true

    def rebuild_payload
      raise Error::UnprocessableEntityError.new("Can only rebuild payload in development environment") unless Rails.env.development?
      self.update(payload: BuildCompletionSnapshotInvoicePayload.call(completion_snapshot, issue_date))
    end
  end
end
