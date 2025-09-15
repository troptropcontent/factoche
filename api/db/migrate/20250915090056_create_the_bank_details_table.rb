class CreateTheBankDetailsTable < ActiveRecord::Migration[8.0]
  def change
    create_table :organization_bank_details do |t|
      t.string :name, null: false
      t.string :iban, null: false
      t.string :bic, null: false
      t.references :company, null: false, foreign_key: { to_table: 'organization_companies' }

      t.timestamps
    end
  end
end
