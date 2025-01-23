class Organization::ProjectVersion < ApplicationRecord
  belongs_to :project

  has_many :items, dependent: :destroy, class_name: "Organization::Item"

  has_many :item_groups, dependent: :destroy, class_name: "Organization::ItemGroup"
  accepts_nested_attributes_for :item_groups

  has_many :ungrouped_items, -> { where(item_group_id: nil) }, class_name: "Organization::Item"
  accepts_nested_attributes_for :ungrouped_items

  validates :retention_guarantee_rate, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10000 }

  validates :number, presence: true, uniqueness: { scope: :project_id }
  before_validation :set_number_to_next_available_number, on: :create

  private

  def next_available_number
    raise "Project must be set to determine next version number" unless project
    project.versions.maximum(:number).to_i + 1
  end

  def set_number_to_next_available_number
    self.number = next_available_number
  end
end
