class Organization::Project < ApplicationRecord
  belongs_to :company, class_name: "Organization::Company"
  belongs_to :client, class_name: "Organization::Client"
  has_many :versions, dependent: :destroy, class_name: "Organization::ProjectVersion", foreign_key: "project_id"

  has_one :last_version, -> { order(created_at: :desc) }, class_name: "Organization::ProjectVersion"
  accepts_nested_attributes_for :versions

  belongs_to :bank_detail, class_name: "Organization::BankDetail"
  validates :bank_detail_id, presence: true

  validates :name, presence: true, uniqueness: { scope: [ :client_id, :type ] }

  validates :posted_at, absence: true, unless: :posted?
  validates :posted_at, presence: true, if: :posted?

  belongs_to :original_project_version,
               class_name: "Organization::ProjectVersion",
               foreign_key: :original_project_version_id, optional: true

  def status
    # TODO : Implement the logic
    "new"
  end
end
