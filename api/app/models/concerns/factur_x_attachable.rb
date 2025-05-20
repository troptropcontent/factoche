module FacturXAttachable
  extend ActiveSupport::Concern

  included do
    has_one_attached :factur_x
  end

  def factur_x_url
    factur_x.attached? ? Rails.application.routes.url_helpers.rails_blob_path(factur_x, only_path: true, disposition: "attachment") : nil
  end
end
