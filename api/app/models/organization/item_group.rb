class Organization::ItemGroup < ApplicationRecord
  belongs_to :project_version, class_name: "Organization::ProjectVersion"
  validates_uniqueness_of :name, scope: :project_version_id
end
