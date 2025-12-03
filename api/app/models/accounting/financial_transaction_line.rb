class Accounting::FinancialTransactionLine < ApplicationRecord
  belongs_to :financial_transaction, class_name: "Accounting::FinancialTransaction"

  # Enum for line kinds
  enum :kind, {
    charge: "charge",
    discount: "discount"
  }

  validates :holder_id, uniqueness: { scope: :financial_transaction_id, message: "has already been taken for this financial transaction" }

  validates :unit, :unit_price_amount, :quantity, :tax_rate, :excl_tax_amount, presence: true
  validates :kind, presence: true

  # Charges have positive amounts
  validates :unit_price_amount, :excl_tax_amount,
            numericality: { greater_than_or_equal_to: 0 }, if: -> { charge? }

  # Discounts have negative amounts
  validates :unit_price_amount, :excl_tax_amount,
            numericality: { less_than_or_equal_to: 0 }, if: -> { discount? }

  validates :quantity,
            numericality: { greater_than_or_equal_to: 0 }

  validates :tax_rate,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }

  validate :validate_excl_tax_amount_calculation

  private

  def validate_excl_tax_amount_calculation
    return unless excl_tax_amount.present?
    return if [ quantity, unit_price_amount ].all? && excl_tax_amount.round(2) == (expected_amount = quantity * unit_price_amount).round(2)

    errors.add(:excl_tax_amount, "must equal quantity * unit_price_amount (#{expected_amount})")
  end
end
