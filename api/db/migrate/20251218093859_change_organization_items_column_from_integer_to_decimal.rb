class ChangeOrganizationItemsColumnFromIntegerToDecimal < ActiveRecord::Migration[8.0]
  def up
    change_column :organization_items, :quantity, :decimal, precision: 10, scale: 2
  end

  def down
    change_column :organization_items, :quantity, :integer
  end
end
