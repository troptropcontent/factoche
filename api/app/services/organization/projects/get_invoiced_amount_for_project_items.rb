module Organization
  module Projects
    class GetInvoicedAmountForProjectItems
      class << self
        def call(company_id, project_id, issue_date = Time.current)
          original_item_uuids = fetch_original_item_uuids(project_id)

          invoiced_amounts = fetch_invoiced_amounts_for_items(company_id, original_item_uuids, issue_date)

          result = original_item_uuids.map do |original_item_uuid|
            {
              original_item_uuid: original_item_uuid,
              invoiced_amount: invoiced_amounts[original_item_uuid] || 0.to_d
            }
          end

          ServiceResult.success(result)
        rescue StandardError => e
          ServiceResult.failure("Failed to get invoiced amounts for project items: #{e.message}")
        end

        private

        def fetch_invoiced_amounts_for_items(company_id, original_item_uuids, issue_date)
          return {} if original_item_uuids.empty?

          Accounting::FinancialTransactionLine
            .joins(:financial_transaction)
            .where(
              financial_transaction: {
                company_id: company_id,
                issue_date: ...issue_date
              },
              holder_id: original_item_uuids
            )
            .select(
              "accounting_financial_transaction_lines.holder_id",
              "SUM(CASE
                WHEN type LIKE '%#{Accounting::FinancialTransaction::InvoiceType}' THEN excl_tax_amount
                WHEN type LIKE '%#{Accounting::FinancialTransaction::CreditNoteType}' THEN -excl_tax_amount
                ELSE 0
              END) as total_amount"
            )
            .group(:holder_id)
            .each_with_object({}) { |record, hash| hash[record.holder_id] = record.total_amount.to_d }
        end

        def fetch_original_item_uuids(project_id)
          Organization::Item
            .joins(:project_version)
            .where(project_version: { project_id: project_id })
            .pluck(:original_item_uuid)
            .uniq
        end
      end
    end
  end
end
