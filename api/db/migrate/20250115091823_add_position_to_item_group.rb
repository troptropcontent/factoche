class AddPositionToItemGroup < ActiveRecord::Migration[8.0]
  def change
    add_column :organization_item_groups, :position, :integer, null: false
  end
end
