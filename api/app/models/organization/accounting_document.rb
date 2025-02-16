class Organization::AccountingDocument < ApplicationRecord
  has_one_attached :pdf
  has_one_attached :xml

  validates :type, presence: true
  validates :total_excl_tax_amount, numericality: { greater_than_or_equal_to: 0 }
end
