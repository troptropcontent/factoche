class Accounting::Payment < ApplicationRecord
  belongs_to :invoice, class_name: "Accounting::Invoice"

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :received_at, presence: true
end
