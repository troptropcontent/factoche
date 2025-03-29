class AddColumnsToConfig < ActiveRecord::Migration[8.0]
  def change
    add_column :organization_company_configs, :default_vat_rate, :decimal, precision: 10, scale: 2, default: 0.20, null: false
    add_column :organization_company_configs, :payment_term_days, :integer, default: 30, null: false
    add_column :organization_company_configs, :payment_term_accepted_methods, :string, array: true, default: [ "transfer" ], null: false
  end
end
