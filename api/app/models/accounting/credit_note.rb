module Accounting
  class CreditNote < FinancialTransaction
    CONTEXT = Invoice::Context
    NUMBER_PREFIX = "CN".freeze
    enum :status,
          {
            draft: "draft",
            posted: "posted"
          },
          default: :draft,
          validate: true
          validate :valid_number

    validate :valid_number

    belongs_to :invoice, class_name: "Accounting::Invoice", foreign_key: :holder_id

    private

    def valid_number
      regex = /^#{NUMBER_PREFIX}-\d{4}-\d+$/
      unless number.match?(regex)
        errors.add(:number, "must match format #{NUMBER_PREFIX}-YEAR-SEQUENCE")
      end
    end
  end
end
