module Accounting
  class FinancialTransaction < ApplicationRecord
    include PdfAttachable

    InvoiceType = "Invoice".freeze
    CreditNoteType = "CreditNote".freeze
    ProformaType = "Proforma".freeze

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
    validate :valid_number

    def total_amount
      total_excl_tax_amount
    end

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
      unless type.demodulize == InvoiceType || type.demodulize == CreditNoteType || type.demodulize == ProformaType
        errors.add(:type, "must either be Invoice, CreditNote or Proforma")
      end
    end

    def valid_number
      return unless self.number.present?
      prefix = self.class.const_get("NUMBER_PREFIX")

      regex = /^#{prefix}-\d{4}-\d+$/
      unless number.match?(regex)
        errors.add(:number, "must match format #{prefix}-YEAR-SEQUENCE")
      end
    end
  end
end
