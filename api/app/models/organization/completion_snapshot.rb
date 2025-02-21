class Organization::CompletionSnapshot < ApplicationRecord
  belongs_to :project_version, class_name: "Organization::ProjectVersion"
  has_many :completion_snapshot_items, class_name: "Organization::CompletionSnapshotItem", dependent: :destroy
  accepts_nested_attributes_for :completion_snapshot_items
  has_one :invoice, class_name: "Organization::Invoice"
  has_one :credit_note, class_name: "Organization::CreditNote"

  delegate :status, to: :invoice
end
