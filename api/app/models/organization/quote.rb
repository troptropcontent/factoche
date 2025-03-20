module Organization
  class Quote < Project
    NUMBER_PREFIX = "QUO".freeze
    validates :original_quote_version_id, absence: true
    has_many :orders, through: :versions

    def status
      orders.any? ? "validated" : "draft"
    end
  end
end
