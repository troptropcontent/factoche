module Accounting
  class CreditNote < FinancialTransaction
    CONTEXT = Invoice::Context

    NUMBER_PREFIX = "CN".freeze

    enum :status,
          {
            posted: "posted"
          },
          default: :posted,
          validate: true
          validate :valid_number

    belongs_to :invoice, class_name: "Accounting::Invoice", foreign_key: :holder_id
  end
end
