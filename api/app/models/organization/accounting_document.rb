class Organization::AccountingDocument < ApplicationRecord
  belongs_to :completion_snapshot, class_name: "Organization::CompletionSnapshot"
  has_one_attached :pdf
  has_one_attached :xml

  validates :type, presence: true
  validates :total_amount_cents, numericality: { greater_than_or_equal_to: 0 }
end
