module Organization
  module CreditNotes
    class NextAvailableNumber
      class << self
        def call(company, issue_date)
          year = issue_date.year
          credit_note_count = company.credit_notes.where(issue_date: issue_date.beginning_of_year..issue_date.end_of_year).count


          "CN-#{year}-#{(credit_note_count + 1).to_s.rjust(6, "0")}"
        end
      end
    end
  end
end
