class Organization::ItemGroup < ApplicationRecord
  belongs_to :project_version, class_name: "Organization::ProjectVersion"

  has_many :items, class_name: "Organization::Item"
  accepts_nested_attributes_for :items

  validates_uniqueness_of :name, scope: :project_version_id
end
