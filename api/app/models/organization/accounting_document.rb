class Organization::AccountingDocument < ApplicationRecord
  has_one_attached :pdf
  has_one_attached :xml

  validates :type, presence: true
  validates :total_excl_tax_amount, numericality: { greater_than_or_equal_to: 0 }

  def pdf_url
    return if pdf.nil?
    Rails.application.routes.url_helpers.rails_blob_path(pdf, only_path: true, disposition: "attachment")
  end
end
