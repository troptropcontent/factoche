class RemovePolymorphicAssociationFromItem < ActiveRecord::Migration[8.0]
  def change
    remove_reference :organization_items, :holder, polymorphic: true

    add_reference :organization_items, :project_version, null: false, foreign_key: { to_table: :organization_project_versions }
    add_reference :organization_items, :item_group, null: true, foreign_key: { to_table: :organization_item_groups }
  end
end
