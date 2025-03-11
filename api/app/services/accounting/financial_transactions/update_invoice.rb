module Accounting
  module FinancialTransactions
    class UpdateInvoice
      class << self
        # Updates an invoice with its detail and invoice lines for a project version
        def call(invoice_id, company, client, project_version, invoice_items, issue_date = Time.current)
          updated_invoice = ActiveRecord::Base.transaction do
            invoice = Accounting::CompletionSnapshotInvoice.find(invoice_id)
            # Update invoice record
            invoice_attributes = build_draft_invoice_attributes!(company.fetch(:id), project_version, issue_date)
            invoice.update!(invoice_attributes)

            # Drop old invoice_lines
            invoice.lines.delete_all

            # Create invoice line records
            invoice_lines_attributes = build_invoice_lines_attributes!(invoice.context, invoice_items)
            invoice.lines.create!(invoice_lines_attributes)

            # Update invoice details records
            invoice_detail_attributes = build_invoice_detail_attributes!(company, client, project_version, issue_date)
            invoice.detail.update!(invoice_detail_attributes)
            invoice
          end

          ServiceResult.success(updated_invoice)
        rescue StandardError => e
          ServiceResult.failure("Failed to update invoice: #{e.message}")
        end

        private

        def build_draft_invoice_attributes!(company_id, project_version, issue_date)
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
