module Organization
  module Invoices
    class ComputeInvoicedAmountForItem
      class << self
        def call(original_item_uuid, issue_date)
            ServiceResult.success(invoices_total_amount(original_item_uuid, issue_date) - credit_notes_total_amount(original_item_uuid, issue_date))
        rescue StandardError => e
          ServiceResult.failure(e)
        end

        private

        def invoices_total_amount(original_item_uuid, issue_date)
          Organization::Invoice.from("organization_invoices, LATERAL jsonb_array_elements(organization_invoices.payload->'transaction'->'items') as items(item)")
                               .where("items.item->>'original_item_uuid' = ?", original_item_uuid)
                               .where(issue_date: ...issue_date)
                               .where.not({ status: :draft })
                               .sum("(items.item->>'invoice_amount')::decimal")
        end

        def credit_notes_total_amount(original_item_uuid, issue_date)
          Organization::CreditNote.from("organization_credit_notes, LATERAL jsonb_array_elements(organization_credit_notes.payload->'transaction'->'items') as items(item)")
                               .where("items.item->>'original_item_uuid' = ?", original_item_uuid)
                               .where(issue_date: ...issue_date)
                               .where.not({ status: :draft })
                               .sum("(items.item->>'credit_note_amount')::decimal")
        end
      end
    end
  end
end
