class AddNullFalseToNameColumnOfItemGroups < ActiveRecord::Migration[8.0]
  def change
    change_column_null :organization_item_groups, :name, false
  end
end
