module Organization
  class Quote < Project
    validates :original_quote_version_id, absence: true

    def status
      Order.where(original_quote_version_id: versions.pluck(:id)).exists? ? "validated" : "draft"
    end
  end
end
