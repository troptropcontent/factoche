class Organization::Company < ApplicationRecord
  has_many :members, dependent: :destroy, class_name: "Organization::Member"
  has_many :users,
           through: :members,
           class_name: "User"


  validates :name, presence: true
  validates :phone, phone: true, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true, uniqueness: true
  validates :address_street, presence: true
  validates :address_city, presence: true
  validates :address_zipcode, presence: true
  validates :address_street, presence: true
  validates :registration_number, presence: true
end
