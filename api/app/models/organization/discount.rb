class Organization::Discount < ApplicationRecord
  belongs_to :project_version, class_name: "Organization::ProjectVersion"

  # Enum for discount kinds
  enum :kind, {
    percentage: "percentage",
    fixed_amount: "fixed_amount"
  }

  validates :name, presence: true
  validates :kind, presence: true
  validates :value, presence: true, numericality: { greater_than: 0 }
  validates :value, numericality: { less_than_or_equal_to: 1 }, if: -> { percentage? }
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :position, presence: true, uniqueness: { scope: :project_version_id }
  validates :original_discount_uuid, presence: true

  scope :ordered, -> { order(:position) }
end
