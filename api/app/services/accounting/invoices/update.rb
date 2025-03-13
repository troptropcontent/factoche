module Accounting
  module Invoices
    class Update
      class << self
        # 'Updates' an invoice by seting the status to the invoice to 'voided' and by recreating a new draft one with with the updated attributes
        def call(invoice_id, company, client, project_version, invoice_items, issue_date = Time.current)
          new_draft_invoice = ActiveRecord::Base.transaction do
            current_invoice = Accounting::Invoice.find(invoice_id)
            # Void current invoice
            current_invoice.update(status: :voided)
            # Create a new invoice to replace the current one
            new_draft_invoice = create_new_draft_invoice!(company, client, project_version, invoice_items, issue_date)

            new_draft_invoice
          end

          ServiceResult.success(new_draft_invoice)
        rescue StandardError => e
          ServiceResult.failure("Failed to update invoice: #{e.message}")
        end

        private

        def create_new_draft_invoice!(company, client, project_version, invoice_items, issue_date)
          result = Invoices::Create.call(company, client, project_version, invoice_items, issue_date)

          raise result.error if result.failure?
          result.data
        end
      end
    end
  end
end
