module Organization
  class Quote < Project
    NUMBER_PREFIX = "QUO".freeze
    validates :original_project_version_id, absence: true

    has_many :draft_orders, through: :versions
  end
end
