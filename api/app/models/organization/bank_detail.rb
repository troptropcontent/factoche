class Organization::BankDetail < ApplicationRecord
  belongs_to :company, class_name: "Organization::Company"
  # has_many :projects, dependent: :destroy, class_name: "Organization::Project"

  validates :name, presence: true, uniqueness: { scope: :company_id }
  validates :iban, presence: true, uniqueness: { scope: :company_id }
  validates :bic, presence: true
end
