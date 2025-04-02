class Organization::ProjectVersion < ApplicationRecord
  include PdfAttachable

  belongs_to :project, class_name: "Organization::Project"

  has_many :items, dependent: :destroy, class_name: "Organization::Item"

  has_many :item_groups, dependent: :destroy, class_name: "Organization::ItemGroup"
  accepts_nested_attributes_for :item_groups

  has_many :ungrouped_items, -> { where(item_group_id: nil) }, class_name: "Organization::Item"
  accepts_nested_attributes_for :ungrouped_items

  has_many :completion_snapshots, class_name: "Organization::CompletionSnapshot"

  has_one :order, class_name: "Organization::Order", foreign_key: :original_project_version_id, dependent: :destroy
  has_one :draft_order, class_name: "Organization::DraftOrder", foreign_key: :original_project_version_id, dependent: :destroy

  validates :retention_guarantee_rate, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }

  validates :number, presence: true, uniqueness: { scope: :project_id }
  before_validation :set_number_to_next_available_number, on: :create

  scope :lasts, -> { joins("JOIN (SELECT MAX(number), project_id FROM organization_project_versions GROUP BY project_id) as max_project_version_numbers ON organization_project_versions.project_id = max_project_version_numbers.project_id").where("max_project_version_numbers.max = organization_project_versions.number") }

  def is_last_version?
    self.class.lasts.exists?(id)
  end

  def total_amount
    items.sum("(quantity * unit_price_amount)").to_d
  end

  private

  def next_available_number
    raise "Project must be set to determine next version number" unless project
    project.versions.maximum(:number).to_i + 1
  end

  def set_number_to_next_available_number
    self.number = next_available_number
  end
end
