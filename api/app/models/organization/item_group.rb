class Organization::ItemGroup < ApplicationRecord
  belongs_to :project_version, class_name: "Organization::ProjectVersion"

  has_many :grouped_items, dependent: :destroy, class_name: "Organization::Item", foreign_key: "item_group_id"
  accepts_nested_attributes_for :grouped_items

  validates_uniqueness_of :name, scope: :project_version_id
end
