class Organization::Project < ApplicationRecord
  belongs_to :client
  validates :name, presence: true, uniqueness: { scope: :client_id }
  validates :retention_guarantee_rate, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
end
