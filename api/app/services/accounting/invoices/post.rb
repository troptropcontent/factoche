module Accounting
  module Invoices
    class Post
      class << self
        # Post and invoice by voiding the current one and creating a posted one identical
        # @param invoice_id [Integer] ID of the invoice to post
        # @param issue_date [Time] When the duplicate invoice should be issued (defaults to current time)
        #
        # @return [ServiceResult] Success with duplicated Invoice or failure with error message
        def call(invoice_id, issue_date = Time.current)
          original_invoice = Accounting::Invoice.find(invoice_id)

          ensure_invoice_is_draft!(original_invoice)

          posted_invoice = ActiveRecord::Base.transaction do
            # Void original invoice
            original_invoice.update!(status: :voided)

            # Find next available number
            next_available_invoice_number = find_next_available_invoice_number!(original_invoice.company_id, issue_date)

            # Duplicate base invoice attributes
            base_attributes = original_invoice.attributes.except(
              "id", "number", "status", "created_at", "updated_at"
            ).merge({
              "number" => next_available_invoice_number,
              "status" => "posted",
              "issue_date" => issue_date
            })

            # Create duplicated invoice
            duplicated_invoice = Accounting::Invoice.create!(base_attributes)

            # Duplicate invoice lines
            original_invoice.lines.each do |line|
              line_attributes = line.attributes.except("id", "invoice_id", "created_at", "updated_at")
              duplicated_invoice.lines.create!(line_attributes)
            end

            # Duplicate invoice details
            if original_invoice.detail.present?
              detail_attributes = original_invoice.detail.attributes.except(
                "id", "invoice_id", "created_at", "updated_at"
              )
              duplicated_invoice.create_detail!(detail_attributes)
            end

            duplicated_invoice
          end

          FinancialTransactions::GenerateAndAttachPdfJob.perform_async({ "financial_transaction_id" => posted_invoice.id })

          ServiceResult.success(posted_invoice)
        rescue StandardError => e
          ServiceResult.failure("Failed to duplicate invoice: #{e.message}")
        end

        private

        def find_next_available_invoice_number!(company_id, issue_date)
          result = FinancialTransactions::FindNextAvailableNumber.call(company_id: company_id, prefix: Invoice::NUMBER_PUBLISHED_PREFIX, issue_date: issue_date)

          raise result.error unless result.success?
          result.data
        end

        def ensure_invoice_is_draft!(invoice)
          unless invoice.status == "draft"
            raise ArgumentError, "Cannot post invoice that is not in draft status"
          end
        end
      end
    end
  end
end
