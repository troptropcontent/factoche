class Organization::AccountingDocument < ApplicationRecord
  belongs_to :completion_snapshot, class_name: "Organization::CompletionSnapshot"
  has_one_attached :pdf
  has_one_attached :xml

  validates :type, presence: true
  validates :total_excl_tax_amount, numericality: { greater_than_or_equal_to: 0 }

  enum :status, {
    draft: "draft",
    published: "published",
    posted: "posted"
  }, default: :draft, validate: true

  def pdf_url
    return unless pdf.attached?
    Rails.application.routes.url_helpers.rails_blob_path(pdf, only_path: true, disposition: "attachment")
  end
end
