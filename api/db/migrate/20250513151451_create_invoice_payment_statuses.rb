class CreateInvoicePaymentStatuses < ActiveRecord::Migration[8.0]
  def change
    create_view :invoice_payment_statuses
  end
end
