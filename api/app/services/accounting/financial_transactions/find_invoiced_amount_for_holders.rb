module Accounting
  module FinancialTransactions
    class FindInvoicedAmountForHolders
      class << self
        def call(holder_ids, issue_date = Time.current)
          invoiced_amount = Accounting::FinancialTransaction
            .joins(:lines)
            .where("type LIKE '%#{Accounting::FinancialTransaction::InvoiceType}'")
            .where(lines: { holder_id: holder_ids }, issue_date: ...issue_date)
            .select("lines.holder_id as line_holder_id, SUM(lines.excl_tax_amount)")
            .group("lines.holder_id")
            .each_with_object({}) { |record, object| object[record.line_holder_id] = record.sum }

          credit_note_amount = Accounting::FinancialTransaction
            .joins(:lines)
            .where("type LIKE '%#{Accounting::FinancialTransaction::CreditNoteType}'")
            .where(lines: { holder_id: holder_ids }, issue_date: ...issue_date)
            .select("lines.holder_id as line_holder_id, SUM(lines.excl_tax_amount)")
            .group("lines.holder_id")
            .each_with_object({}) { |record, object| object[record.line_holder_id] = record.sum }

          result = [ *invoiced_amount.keys, *credit_note_amount.keys ].uniq.map do |line_holder_id|
            {
              holder_id: line_holder_id,
              invoiced_amount: invoiced_amount[line_holder_id] || 0.to_d,
              credit_note_amount: credit_note_amount[line_holder_id] || 0.to_d
            }
          end

          ServiceResult.success(result)
        rescue StandardError => e
          ServiceResult.failure("Failed to find invoiced amounts for holder_ids: #{holder_ids}. Error: #{e.message}")
        end
      end
    end
  end
end
