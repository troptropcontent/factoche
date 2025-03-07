class AddTaxRateToOrganizationItems < ActiveRecord::Migration[8.0]
  def change
    add_column :organization_items, :tax_rate, :decimal, precision: 5, scale: 2
  end
end
