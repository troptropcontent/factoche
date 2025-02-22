module Organization
  module CreditNotes
    class NextAvailableNumber
      class << self
        def call(company)
          credit_notes_count = company.credit_notes.count

          "CN-#{(credit_notes_count + 1).to_s.rjust(6, "0")}"
        end
      end
    end
  end
end
