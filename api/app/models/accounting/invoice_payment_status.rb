class Accounting::InvoicePaymentStatus < ApplicationRecord
  self.table_name = "invoice_payment_statuses"

  belongs_to :invoice, class_name: "Accounting::Invoice"

  def readonly?
    true
  end
end
