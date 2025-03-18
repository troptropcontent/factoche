class CreateOrganizationItems < ActiveRecord::Migration[8.0]
  def change
    create_table :organization_items do |t|
      t.references :holder, polymorphic: true, null: false
      t.string :name, null: false
      t.string :description
      t.integer :quantity, null: false
      t.string :unit, null: false
      t.decimal :unit_price_amount, precision: 15, scale: 2, null: false

      t.timestamps
    end
  end
end
