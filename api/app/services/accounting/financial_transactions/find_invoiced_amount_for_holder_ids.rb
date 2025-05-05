module Accounting
  module FinancialTransactions
    class FindInvoicedAmountForHolderIds
      include ApplicationService

      CREDIT_NOTE_LINE_TYPE = "credit_note_amount".freeze
      INVOICE_LINE_TYPE = "invoice_amount".freeze

      def call(holder_ids, issue_date = Time.current)
        @holder_ids =  holder_ids
        @issue_date =  issue_date
        @lines = []

        fetch_invoice_amounts!

        fetch_credit_note_amounts!

        build_amounts_for_holder_ids!
      end

      private

      def fetch_invoice_amounts!
        @lines += Accounting::FinancialTransactionLine.joins(:financial_transaction)
                                                      .where(holder_id: @holder_ids,
                                                            financial_transaction: { issue_date: ...@issue_date, type: Accounting::Invoice.name })
                                                      .select("accounting_financial_transaction_lines.holder_id, SUM(total_excl_tax_amount) as sum, '#{INVOICE_LINE_TYPE}' as type")
                                                      .group("holder_id")
      end

      def fetch_credit_note_amounts!
        @lines += Accounting::FinancialTransactionLine.joins(:financial_transaction)
                                                      .where(holder_id: @holder_ids,
                                                            financial_transaction: { issue_date: ...@issue_date, type: CreditNote.name })
                                                      .select("accounting_financial_transaction_lines.holder_id, SUM(total_excl_tax_amount) as sum, '#{CREDIT_NOTE_LINE_TYPE}' as type")
                                                      .group("holder_id")
      end

      def build_amounts_for_holder_ids!
        @lines.each_with_object(Hash.new { |hash, key| hash[key] = { invoices_amount: 0, credit_notes_amount: 0 } }) do |line, result|
          amount_key = line.type == INVOICE_LINE_TYPE ? :invoices_amount : :credit_notes_amount
          result[line.holder_id][amount_key] += line.sum
        end
      end
    end
  end
end
