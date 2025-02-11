class Organization::Project < ApplicationRecord
  belongs_to :client, class_name: "Organization::Client"
  has_many :versions, dependent: :destroy, class_name: "Organization::ProjectVersion", foreign_key: "project_id"
  has_many :completion_snapshots, through: :versions, class_name: "Organization::CompletionSnapshot"
  has_many :invoices, through: :completion_snapshots, class_name: "Organization::Invoice"
  has_many :credit_notes, through: :completion_snapshots, class_name: "Organization::CreditNote"
  has_one :last_version, -> { order(created_at: :desc) }, class_name: "Organization::ProjectVersion"
  accepts_nested_attributes_for :versions

  validates :name, presence: true, uniqueness: { scope: :client_id }

  def status
    # TODO : Implement the logic
    "new"
  end
end
