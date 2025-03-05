module Accounting
  module FinancialTransactions
    class BuildCompletionSnapshotInvoiceAttributes
      class << self
        def call(company_id, project_version, issue_date)
          attributes = {
            company_id: company_id,
            holder_id: project_version.fetch(:id),
            status: :draft,
            issue_date: issue_date,
            context: build_draft_invoice_context(project_version, issue_date)
          }

          ServiceResult.success(attributes)
        rescue StandardError => e
          ServiceResult.failure("Failed to build invoice attributes for company_id: #{company_id}, " \
                              "project_version: #{project_version[:number]}, issue_date: #{issue_date}. " \
                              "Error: #{e.message}")
        end

        private

        def build_draft_invoice_context(project_version, issue_date)
          project_version_items = build_project_version_items_data(project_version.fetch(:items), issue_date)

          {
            project_version_number: project_version.fetch(:number),
            project_version_date: project_version.fetch(:created_at).iso8601,
            project_version_retention_guarantee_rate: project_version.fetch(:retention_guarantee_rate),
            project_total_amount: find_project_version_total(project_version_items),
            project_total_previously_billed_amount: project_version_items.sum { |project_version_item| project_version_item.fetch(:previously_billed_amount) },
            project_version_items: project_version_items,
            project_version_item_groups: build_project_version_item_groups_data(project_version.fetch(:item_groups))
          }
        end

        def build_project_version_items_data(project_version_items, issue_date)
          project_version_items.map do |item|
            {
              original_item_uuid: item.fetch(:original_item_uuid),
              group_id: item.fetch(:group_id),
              name: item.fetch(:name),
              description: item.fetch(:description),
              quantity: item.fetch(:quantity),
              unit: item.fetch(:unit),
              unit_price_amount: item.fetch(:unit_price_amount),
              tax_rate: item.fetch(:tax_rate),
              previously_billed_amount: find_previously_invoiced_amount_for_item(item.fetch(:original_item_uuid), issue_date)
            }
          end
        end

        def find_project_version_total(project_version_items)
          project_version_items.sum do |project_version_item|
            project_version_item.fetch(:quantity) * project_version_item.fetch(:unit_price_amount)
          end
        end

        def build_project_version_item_groups_data(project_version_item_groups)
          project_version_item_groups.map do |group|
            {
              id: group.fetch(:id),
              name: group.fetch(:name),
              description: group.fetch(:description)
            }
          end
        end

        def find_previously_invoiced_amount_for_item(original_item_uuid, issue_date)
          Accounting::FinancialTransactionLine.joins(:financial_transaction)
            .where(
              holder_id: original_item_uuid,
              financial_transaction: { issue_date: ...issue_date, status: :posted }
            )
            .sum("(unit_price_amount * quantity)")
        end
      end
    end
  end
end
