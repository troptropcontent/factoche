class Organization::CompletionSnapshot < ApplicationRecord
  belongs_to :project_version, class_name: "Organization::ProjectVersion"
  has_many :completion_snapshot_items, class_name: "Organization::CompletionSnapshotItem"
  accepts_nested_attributes_for :completion_snapshot_items

  scope :draft, -> { where("invoice_id IS NULL") }
  scope :invoiced, -> { where("invoice_id IS NOT NULL AND credit_note_id IS NULL") }
  scope :cancelled, -> { where("invoice_id IS NOT NULL AND credit_note_id IS NOT NULL") }

  validate :only_one_new_completion_snapshot_per_project

  private

  def only_one_new_completion_snapshot_per_project
    true
    # if project_version.project.completion_snapshots.draft && expiration_date < Date.today
    #   errors.add(:base, "can't be in the past")
    # end
  end
end
