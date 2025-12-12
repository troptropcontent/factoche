class AddKindToFinancialTransactionLines < ActiveRecord::Migration[8.0]
  def change
    # Create enum type for financial transaction line kinds
    create_enum :financial_transaction_line_kind, [ "charge", "discount" ]

    add_column :accounting_financial_transaction_lines, :kind, :enum,
               enum_type: "financial_transaction_line_kind",
               null: false,
               default: "charge"

    add_index :accounting_financial_transaction_lines, :kind
  end
end
