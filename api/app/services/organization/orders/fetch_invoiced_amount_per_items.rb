module Organization
  module Orders
    # Fetches and calculates the total invoiced and credit-noted amounts for each item in an order
    #
    # @param order_id [Integer] The ID of the order to calculate amounts for
    #
    # @param issue_date [Time] Optional date to filter transactions before (defaults to Time.current)
    #
    # @return [Hash] A hash where keys are holder_ids and values are hashes containing:
    #   - invoices_amount: The total amount invoiced for this holder
    #   - credit_notes_amount: The total amount credit-noted for this holder
    class FetchInvoicedAmountPerItems
      include ApplicationService

      LINE_TYPES = {
        invoice: "invoice_line",
        credit_note: "credit_note_line"
      }.freeze

      def initialize
        @lines = []
      end

      def call(order_id, issue_date = Time.current)
        @order = Order.find(order_id)
        @issue_date = issue_date

        fetch_invoice_lines
        fetch_credit_note_lines
        calculate_amounts_per_holder
      end

      private

      def fetch_invoice_lines
        @invoice_lines = Accounting::FinancialTransactionLine
                         .joins(:financial_transaction)
                         .where(financial_transaction: { type: Accounting::Invoice.name, holder_id: @order.versions.pluck(:id), issue_date: ...@issue_date })
        append_lines(@invoice_lines, LINE_TYPES[:invoice])
      end

      def fetch_credit_note_lines
        @credit_note_lines = Accounting::FinancialTransactionLine
                             .joins(:financial_transaction)
                             .where(financial_transaction: { type: Accounting::CreditNote.name, holder_id: @invoice_lines.pluck(:financial_transaction_id) })
        append_lines(@credit_note_lines, LINE_TYPES[:credit_note])
      end

      def append_lines(lines, line_type)
        @lines += lines.select("accounting_financial_transaction_lines.holder_id, SUM(excl_tax_amount) as sum, '#{line_type}' as type")
                       .group(:holder_id)
      end

      def calculate_amounts_per_holder
        @lines.each_with_object(Hash.new { |hash, key| hash[key] = { invoices_amount: 0, credit_notes_amount: 0 } }) do |line, result|
          amount_key = line.type == LINE_TYPES[:invoice] ? :invoices_amount : :credit_notes_amount
          result[line.holder_id][amount_key] += line.sum
        end
      end
    end
  end
end
