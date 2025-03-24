module PdfAttachable
  extend ActiveSupport::Concern

  included do
    has_one_attached :pdf
  end

  def pdf_url
    pdf.attached? ? Rails.application.routes.url_helpers.rails_blob_path(pdf, only_path: true, disposition: "attachment") : nil
  end
end
