module Accounting
  class Proforma < FinancialTransaction
    Context = Invoice::Context

    NUMBER_PREFIX = "PRO".freeze

    enum :status,
         {
           draft: "draft",
           voided: "voided",
           posted: "posted"
         },
         default: :draft,
         validate: true

    validate :valid_number

    private

    def valid_number
      regex = /^#{NUMBER_PREFIX}-\d{4}-\d+$/
      unless number.match?(regex)
        errors.add(:number, "must match format #{NUMBER_PREFIX}-YEAR-SEQUENCE")
      end
    end
  end
end
