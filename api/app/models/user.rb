class User < ApplicationRecord
  has_secure_password
  has_many :members, dependent: :destroy, class_name: "Organization::Member"
  has_many :companies,
           through: :members,
           class_name: "Organization::Company"
end
