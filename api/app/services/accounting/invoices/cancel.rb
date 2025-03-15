module Accounting
  module Invoices
    class Cancel
      class << self
        def call(invoice_id, issue_date = Time.current)
          raise Error::UnprocessableEntityError, "Invoice ID is required" if invoice_id.blank?
          raise Error::UnprocessableEntityError, "Issue date is required" if issue_date.blank?

          original_invoice = Accounting::Invoice.find(invoice_id)

          ensure_invoice_is_posted!(original_invoice)

          original_invoice, credit_note = ActiveRecord::Base.transaction do
            # Cancel original invoice
            original_invoice.update!(status: :cancelled)

            # Find next available number
            next_available_credit_note_number = find_next_available_credit_note_number!(
              original_invoice.company_id,
              issue_date
            )

            credit_note = create_credit_note!(
              original_invoice,
              next_available_credit_note_number,
              issue_date
            )

            [ original_invoice, credit_note ]
          end

          FinancialTransactions::GenerateAndAttachPdfJob.perform_async(
            { "financial_transaction_id" => credit_note.id }
          )

          ServiceResult.success({ invoice: original_invoice, credit_note: credit_note })
        rescue StandardError => e
          ServiceResult.failure("Failed to cancel invoice: #{e.message}")
        end

        private

        def ensure_invoice_is_posted!(invoice)
          unless invoice.posted?
            raise Error::UnprocessableEntityError, "Cannot cancel invoice that is not in posted status"
          end
        end

        def find_next_available_credit_note_number!(company_id, issue_date)
          result = FinancialTransactions::FindNextAvailableNumber.call(
            company_id: company_id,
            prefix: CreditNote::NUMBER_PREFIX,
            issue_date: issue_date
          )

          raise result.error unless result.success?
          result.data
        end

        def create_credit_note!(original_invoice, number, issue_date)
          # Create credit note

          credit_note = Accounting::CreditNote.create!(
            original_invoice.attributes.except(
              "id", "number", "status", "created_at", "updated_at", "type"
            ).merge(
              "number" => number,
              "status" => "posted",
              "issue_date" => issue_date,
              "holder_id": original_invoice.id
            )
          )

          # Copy lines
          original_invoice.lines.each do |line|
            credit_note.lines.create!(
              line.attributes.except("id", "invoice_id", "created_at", "updated_at")
            )
          end

          # Copy details if present
          if original_invoice.detail.present?
            credit_note.create_detail!(
              original_invoice.detail.attributes.except(
                "id", "invoice_id", "created_at", "updated_at"
              )
            )
          end

          credit_note
        end
      end
    end
  end
end
