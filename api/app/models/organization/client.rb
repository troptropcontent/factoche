class Organization::Client < ApplicationRecord
  belongs_to :company, class_name: "Organization::Company"

  validates :name, presence: true
  validates :phone, phone: true, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true
  validates :address_city, presence: true
  validates :address_zipcode, presence: true
  validates :address_street, presence: true
  validates :registration_number, presence: true, uniqueness: { scope: :company_id }
end
