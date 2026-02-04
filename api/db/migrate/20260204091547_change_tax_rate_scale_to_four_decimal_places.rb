class ChangeTaxRateScaleToFourDecimalPlaces < ActiveRecord::Migration[8.0]
  def change
    change_column :organization_items, :tax_rate, :decimal, precision: 5, scale: 4, null: false
    change_column :accounting_financial_transaction_lines, :tax_rate, :decimal, precision: 15, scale: 4, null: false
  end
end
