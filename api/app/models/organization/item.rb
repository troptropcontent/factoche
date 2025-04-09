class Organization::Item < ApplicationRecord
  belongs_to :project_version, class_name: "Organization::ProjectVersion"
  belongs_to :item_group, class_name: "Organization::ItemGroup", optional: true

  validates :name, presence: true, uniqueness: { scope: [ :project_version_id, :item_group_id ] }
  validates :quantity, presence: true
  validates :unit, presence: true
  validates :unit_price_amount, presence: true
  validates :original_item_uuid, presence: true
  validate :item_group_belongs_to_same_project_version

  def amount_cents
    (unit_price_amount * 100 * quantity)
  end


  private

  def item_group_belongs_to_same_project_version
    return if item_group.nil? # Skip validation if no item_group is assigned

    unless item_group.project_version_id == project_version_id
      errors.add(:item_group, "must belong to the same project version than the item")
    end
  end
end
