module Organization
  module Invoices
    class ComputeInvoicedAmountForItem
      class << self
        def call(project, original_item_uuid, issue_date)
            ServiceResult.success(invoices_total_amount(project, original_item_uuid, issue_date) - credit_notes_total_amount(project, original_item_uuid, issue_date))
        rescue StandardError => e
          ServiceResult.failure(e)
        end

        private

        def invoices_total_amount(project, original_item_uuid, issue_date)
          total = BigDecimal("0")
          project.invoices.where(issue_date: ...issue_date)
          .where.not({ status: :draft })
          .where("payload -> 'transaction' -> 'items' @> ?", [ { original_item_uuid: original_item_uuid } ].to_json)
          .find_each do |invoice|
            invoice_payload_items = invoice.payload.fetch("transaction").fetch("items")
            total += invoice_payload_items.sum do |invoice_item|
              BigDecimal(invoice_item.fetch("original_item_uuid") == original_item_uuid ? invoice_item.fetch("invoice_amount") : "0")
            end
          end
          total
        end

        def credit_notes_total_amount(project, original_item_uuid, issue_date)
          total = BigDecimal("0")
          project.credit_notes
            .where.not({ status: :draft })
            .where(issue_date: ...issue_date)
            .where("organization_credit_notes.payload -> 'transaction' -> 'items' @> ?", [ { original_item_uuid: original_item_uuid } ].to_json)
            .find_each do |credit_note|
              credit_note_payload_items = credit_note.payload.fetch("transaction").fetch("items")
              total += credit_note_payload_items.sum do |credit_note_item|
                 BigDecimal(credit_note_item.fetch("original_item_uuid") == original_item_uuid ? credit_note_item.fetch("credit_note_amount") : "0")
              end
            end
          total
        end
      end
    end
  end
end
