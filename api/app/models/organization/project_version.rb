class Organization::ProjectVersion < ApplicationRecord
  belongs_to :project

  has_many :items, class_name: "Organization::Item"
  accepts_nested_attributes_for :items

  has_many :item_groups, class_name: "Organization::ItemGroup"
  accepts_nested_attributes_for :item_groups

  validates :number, presence: true, uniqueness: { scope: :project_id }
  before_validation :set_number_to_next_available_number, on: :create

  private

  def next_available_number
    raise "Project must be set to determine next version number" unless project_id
    project.project_versions.maximum(:number).to_i + 1
  end

  def set_number_to_next_available_number
    self.number = next_available_number
  end
end
