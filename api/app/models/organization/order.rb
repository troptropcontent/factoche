module Organization
  class Order < Project
    belongs_to :original_quote_version,
               class_name: "Organization::ProjectVersion",
               foreign_key: :original_quote_version_id

    validates :original_quote_version_id, presence: true  # Validation only for Orders
  end
end
