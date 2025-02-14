class AddOriginalItemIdToOrganisationItems < ActiveRecord::Migration[8.0]
  def change
    add_column :organization_items, :original_item_uuid, :uuid, null: false
    add_index :organization_items, :original_item_uuid
  end
end
