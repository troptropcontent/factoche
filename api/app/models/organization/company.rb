class Organization::Company < ApplicationRecord
  WEBSOCKET_CHANNEL_PREFIX = "notifications_company"
  has_many :members, dependent: :destroy, class_name: "Organization::Member"
  has_many :clients, dependent: :destroy, class_name: "Organization::Client"
  has_many :projects, through: :clients, class_name: "Organization::Project"
  has_one :config, dependent: :destroy, class_name: "Organization::CompanyConfig"
  has_many :users, through: :members, class_name: "User"

  enum :legal_form, {
    sasu: "sasu",
    sas: "sas",
    eurl: "eurl",
    sa: "sa",
    auto_entrepreneur: "auto_entrepreneur"
  }, default: :sas, validate: true

  validates :name, presence: true
  validates :phone, phone: true, presence: true
  validates :email,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            presence: true,
            uniqueness: true
  validates :address_street, presence: true
  validates :address_city, presence: true
  validates :address_zipcode, presence: true
  validates :registration_number, presence: true

  def websocket_channel
    [ WEBSOCKET_CHANNEL_PREFIX, id ].join("_")
  end
end
