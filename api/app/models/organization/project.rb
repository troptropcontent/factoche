class Organization::Project < ApplicationRecord
  belongs_to :client
  has_many :versions, class_name: "Organization::ProjectVersion", foreign_key: "project_id"
  accepts_nested_attributes_for :versions

  validates :name, presence: true, uniqueness: { scope: :client_id }
end
