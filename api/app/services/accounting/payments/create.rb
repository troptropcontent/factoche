module Accounting
  module Payments
    class Create
      include ApplicationService

      def call(invoice_id, received_at = Time.current)
        @invoice = Invoice.find(invoice_id)
        @received_at = received_at

        Payment.create!(
          invoice: @invoice,
          amount: @invoice.total_excl_retention_guarantee_amount,
          received_at: @received_at
        )
      end
    end
  end
end
