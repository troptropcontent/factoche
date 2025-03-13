module Accounting
  class FinancialTransaction < ApplicationRecord
    InvoiceType = "Invoice".freeze
    CreditNoteType = "CreditNote".freeze

    has_many :lines,
             class_name: "Accounting::FinancialTransactionLine",
             dependent: :destroy
    has_one :detail,
            class_name: "Accounting::FinancialTransactionDetail",
            dependent: :destroy

    validate :valid_type_name?
    validate :valid_context?
    validates :number,
              presence: true,
              uniqueness: {
                scope: :company_id,
                message: "has already been taken for this company"
              }

    private

    def valid_context?
      return unless self.class.const_defined?("Context")
      return errors.add(:context, "must be a hash") unless context.is_a?(Hash)

      contract = self.class.const_get("Context").new
      result = contract.call(context)

      return if result.success?

      result.errors.to_h.each do |field, messages|
        messages.each do |message|
          errors.add(:context, "#{field} #{message}")
        end
      end
    end

    def valid_type_name?
      unless type.demodulize == InvoiceType || type == CreditNoteType
        errors.add(:type, "must either be Invoice or CreditNote")
      end
    end
  end
end
