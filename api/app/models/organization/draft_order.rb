module Organization
  class DraftOrder < Project
    NUMBER_PREFIX = "DRA".freeze

    has_many :orders, through: :versions
  end
end
