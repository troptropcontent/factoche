module Organization
  class Order < Project
    NUMBER_PREFIX = "ORD".freeze
    belongs_to :original_quote_version,
               class_name: "Organization::ProjectVersion",
               foreign_key: :original_quote_version_id

    validates :original_quote_version_id, presence: true  # Validation only for Orders

    def invoiced_amount
      # TODO : Implement the logic
      0.to_d
    end
  end
end
