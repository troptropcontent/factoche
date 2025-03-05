module Accounting
  module FinancialTransactions
    class UpdateCompletionSnapshotInvoice
      class << self
        def call(invoice_id, company, client, project_version, new_invoice_items, issue_date = Time.current)
          invoice = CompletionSnapshotInvoice.find(invoice_id)
          ensure_invoice_is_draft!(invoice)

          ActiveRecord::Base.transaction do
            # Update invoice record
            invoice_attributes = build_invoice_attributes!(company.fetch(:id), project_version, issue_date)
            invoice.update!(invoice_attributes)

            # Destroy old line records
            invoice.lines.destroy_all

            # Create new lines records
            invoice_lines_attributes = build_invoice_lines_attributes!(invoice.context, new_invoice_items)
            invoice.lines.create!(invoice_lines_attributes)

            # Update invoice detail
            invoice_detail_attributes = build_invoice_detail_attributes!(company, client, project_version, issue_date)
            invoice.detail.update!(invoice_detail_attributes)
            invoice
          end

          ServiceResult.success(invoice)
        rescue StandardError => e
          ServiceResult.failure("Failed to update invoice: #{e.message}")
        end

        private

        def ensure_invoice_is_draft!(invoice)
          unless invoice.status === "draft"
            raise ArgumentError, "Cannot update invoice that is not in draft status"
          end
        end

        def build_invoice_attributes!(company_id, project_version, issue_date)
          result = BuildCompletionSnapshotInvoiceAttributes.call(company_id, project_version, issue_date)

          raise result.error if result.failure?
          result.data
        end

        def build_invoice_lines_attributes!(draft_invoice_context, new_invoice_items)
          result = BuildCompletionSnapshotInvoiceLinesAttributes.call(draft_invoice_context, new_invoice_items)

          raise result.error if result.failure?
          result.data
        end

        def build_invoice_detail_attributes!(company, client, project_version, issue_date)
          result = BuildCompletionSnapshotInvoiceDetailAttributes.call(company, client, project_version, issue_date)

          raise result.error if result.failure?
          result.data
        end
      end
    end
  end
end
