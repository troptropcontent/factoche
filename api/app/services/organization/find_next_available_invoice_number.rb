module Organization
  class FindNextAvailableInvoiceNumber
    def call(company)
      invoice_count = company.invoices.count

        "INV-#{(invoice_count + 1).to_s.rjust(6, "0")}"
    end
  end
end
