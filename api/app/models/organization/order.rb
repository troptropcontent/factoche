module Organization
  class Order < Project
    NUMBER_PREFIX = "ORD".freeze
    belongs_to :original_project_version_id,
               class_name: "Organization::ProjectVersion",
               foreign_key: :original_project_version_id

    validates :original_project_version_id, presence: true

    def invoiced_amount
      # TODO : Implement the logic
      0.to_d
    end
  end
end
