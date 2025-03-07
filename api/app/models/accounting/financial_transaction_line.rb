class Accounting::FinancialTransactionLine < ApplicationRecord
  belongs_to :financial_transaction, class_name: "Accounting::FinancialTransaction"

  validates :holder_id, uniqueness: { scope: :financial_transaction_id, message: "has already been taken for this financial transaction" }

  validates :unit, :unit_price_amount, :quantity, :tax_rate,
            :retention_guarantee_rate, :excl_tax_amount, presence: true

  validates :unit_price_amount, :quantity, :excl_tax_amount,
            numericality: { greater_than_or_equal_to: 0 }

  validates :tax_rate, :retention_guarantee_rate,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }

  validate :validate_excl_tax_amount_calculation

  private

  def validate_excl_tax_amount_calculation
    return if [ quantity, unit_price_amount ].all? && excl_tax_amount.round(2) == (expected_amount = quantity * unit_price_amount).round(2)

    errors.add(:excl_tax_amount, "must equal quantity * unit_price_amount (#{expected_amount})")
  end
end
