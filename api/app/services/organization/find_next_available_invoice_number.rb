module Organization
  class FindNextAvailableInvoiceNumber
    def self.call(company, issue_date)
      invoice_count = company.invoices.where(issue_date: issue_date.beginning_of_year..issue_date.end_of_year).count

        "INV-#{issue_date.year}-#{(invoice_count + 1).to_s.rjust(6, "0")}"
    end
  end
end
