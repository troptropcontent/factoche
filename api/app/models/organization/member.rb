class Organization::Member < ApplicationRecord
  belongs_to :user
  belongs_to :company, class_name: "Organization::Company"
  validates :user_id, uniqueness: { scope: :company_id }
end
