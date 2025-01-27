class Organization::CompletionSnapshot < ApplicationRecord
  belongs_to :project_version, class_name: "Organization::ProjectVersion"
  has_many :completion_snapshot_items, class_name: "Organization::CompletionSnapshotItem"
  accepts_nested_attributes_for :completion_snapshot_items
  belongs_to :invoice, class_name: "Organization::Invoice", optional: true
  belongs_to :credit_note, class_name: "Organization::CreditNote", optional: true

  scope :draft, -> { where("invoice_id IS NULL") }
  scope :invoiced, -> { where("invoice_id IS NOT NULL AND credit_note_id IS NULL") }
  scope :cancelled, -> { where("invoice_id IS NOT NULL AND credit_note_id IS NOT NULL") }
end
