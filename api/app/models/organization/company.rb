class Organization::Company < ApplicationRecord
  validates :phone, presence: true, format: {
    with: /\A\+?[\d\s-]{10,}\z/,
    message: "must be a valid phone number format (minimum 10 digits, can include spaces, dashes and optional + prefix)"
  }
end
