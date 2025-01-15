class Organization::Project < ApplicationRecord
  belongs_to :client
  has_many :project_versions
  accepts_nested_attributes_for :project_versions

  validates :name, presence: true, uniqueness: { scope: :client_id }
end
