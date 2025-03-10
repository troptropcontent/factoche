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

    def self.inherited(subclass)
      super

      if subclass.name.ends_with?(InvoiceType)
        subclass.enum :status,
                     {
                       draft: "draft",
                       posted: "posted",
                       cancelled: "cancelled"
                     },
                     default: :draft,
                     validate: true
      else
        subclass.enum :status,
                     {
                       draft: "draft",
                       posted: "posted"
                     },
                     default: :draft,
                     validate: true
      end
    end

    validates :number,
              presence: true,
              uniqueness: {
                scope: :company_id,
                message: "has already been taken for this company"
              },
              unless: :draft?

    validate :valid_type_name?
    validate :valid_context?

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
      unless type&.ends_with?(InvoiceType) || type&.ends_with?(CreditNoteType)
        errors.add(:type, "must end with Invoice or CreditNote")
      end
    end
  end
end
