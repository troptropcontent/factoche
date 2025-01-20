class AddPositionToItem < ActiveRecord::Migration[8.0]
  def change
    add_column :organization_items, :position, :integer, null: false
  end
end
