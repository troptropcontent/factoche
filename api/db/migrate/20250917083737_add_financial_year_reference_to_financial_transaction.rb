class AddFinancialYearReferenceToFinancialTransaction < ActiveRecord::Migration[8.0]
  def change
    add_reference :accounting_financial_transactions, :financial_year, foreign_key: { to_table: :accounting_financial_years }
  end
end
