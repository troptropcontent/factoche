class AddNotNullToTaxRate < ActiveRecord::Migration[8.0]
  def change
    change_column_null :organization_items, :tax_rate, false
  end
end
