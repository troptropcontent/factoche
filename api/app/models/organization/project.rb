class Organization::Project < ApplicationRecord
  belongs_to :company, class_name: "Organization::Company"
  belongs_to :client, class_name: "Organization::Client"
  has_many :versions, dependent: :destroy, class_name: "Organization::ProjectVersion", foreign_key: "project_id"

  has_one :last_version, -> { order(created_at: :desc) }, class_name: "Organization::ProjectVersion"
  accepts_nested_attributes_for :versions

  validates :name, presence: true, uniqueness: { scope: [ :client_id, :type ] }

  def status
    # TODO : Implement the logic
    "new"
  end
end
