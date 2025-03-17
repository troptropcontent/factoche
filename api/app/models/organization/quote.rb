module Organization
  class Quote < Project
    validates :original_quote_version_id, absence: true
  end
end
