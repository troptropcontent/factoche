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
  end
end
