class CreateAccountingFinancialYears < ActiveRecord::Migration[8.0]
  def change
    create_table :accounting_financial_years do |t|
      t.bigint :company_id, null: false, index: true
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end
  end
end
