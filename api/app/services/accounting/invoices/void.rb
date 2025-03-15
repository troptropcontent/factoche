module Accounting
  module Invoices
    class Void
      class << self
        def call(invoice_id)
          raise Error::UnprocessableEntityError, "Invoice ID is required" if invoice_id.blank?

          invoice = Accounting::Invoice.find(invoice_id)

          ensure_invoice_is_draft!(invoice)

          ActiveRecord::Base.transaction do
            invoice.update!(status: :voided)
          end

          ServiceResult.success(invoice)
        rescue StandardError => e
          ServiceResult.failure(e.message)
        end

        private

        def ensure_invoice_is_draft!(invoice)
          return if invoice.draft?

          raise Error::UnprocessableEntityError, "Cannot void invoice that is not in draft status"
        end
      end
    end
  end
end
