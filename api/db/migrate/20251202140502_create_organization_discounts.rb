class CreateOrganizationDiscounts < ActiveRecord::Migration[8.0]
  def change
    # Create enum type for discount kinds
    create_enum :organization_discount_kind, [ "percentage", "fixed_amount" ]

    create_table :organization_discounts do |t|
      t.references :project_version, null: false, foreign_key: { to_table: :organization_project_versions }
      t.enum :kind, enum_type: "organization_discount_kind", null: false
      t.decimal :value, precision: 15, scale: 6, null: false
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.integer :position, null: false
      t.uuid :original_discount_uuid, null: false
      t.string :name

      t.timestamps
    end

    add_index :organization_discounts, [ :project_version_id, :position ], unique: true, name: 'index_discounts_on_version_and_position'
    add_index :organization_discounts, :original_discount_uuid
  end
end
