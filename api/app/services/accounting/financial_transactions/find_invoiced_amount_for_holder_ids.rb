module Accounting
  module FinancialTransactions
    class FindInvoicedAmountForHolderIds
      include ApplicationService

      LINE_TYPES = {
        invoice: "invoice_line",
        credit_note: "credit_note_line"
      }.freeze

      def initialize
        @lines = []
      end

      def call(holder_ids, issue_date = Time.current)
        @holder_ids = holder_ids
        @issue_date = issue_date

        fetch_invoice_lines
        fetch_credit_note_lines
        calculate_amounts_per_holder
      end

      private

      def fetch_invoice_lines
        @invoice_lines = Accounting::FinancialTransactionLine
                         .joins(:financial_transaction)
                         .where(holder_id: @holder_ids, financial_transaction: { type: Accounting::Invoice.name, issue_date: ...@issue_date })
        append_lines(@invoice_lines, LINE_TYPES[:invoice])
      end

      def fetch_credit_note_lines
        @credit_note_lines = Accounting::FinancialTransactionLine
                             .joins(:financial_transaction)
                             .where(holder_id: @holder_ids, financial_transaction: { type: Accounting::CreditNote.name, issue_date: ...@issue_date })
        append_lines(@credit_note_lines, LINE_TYPES[:credit_note])
      end

      def append_lines(lines, line_type)
        @lines += lines.select("accounting_financial_transaction_lines.holder_id, SUM(excl_tax_amount) as sum, '#{line_type}' as type")
                       .group(:holder_id)
      end

      def calculate_amounts_per_holder
        @lines.each_with_object(Hash.new { |hash, key| hash[key] = { invoices_amount: 0.to_d, credit_notes_amount: 0.to_d } }) do |line, result|
          amount_key = line.type == LINE_TYPES[:invoice] ? :invoices_amount : :credit_notes_amount
          result[line.holder_id][amount_key] += line.sum
        end
      end
    end
  end
end
