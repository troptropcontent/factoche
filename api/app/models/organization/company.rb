class Organization::Company < ApplicationRecord
  validates :name, presence: true
  validates :phone, phone: true, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true, uniqueness: true
  validates :address_street, presence: true
  validates :address_city, presence: true
  validates :address_zipcode, presence: true
  validates :address_street, presence: true
  validates :registration_number, presence: true
end
