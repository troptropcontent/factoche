module Organization
  class Order < Project
    NUMBER_PREFIX = "ORD".freeze

    validates :original_project_version_id, presence: true

    def invoiced_amount
      # TODO : Implement the logic
      0.to_d
    end
  end
end
