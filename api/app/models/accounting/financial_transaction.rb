class Accounting::FinancialTransaction < ApplicationRecord
  enum :status, {
      draft: "draft",
      posted: "posted"
  }, default: :draft, validate: true

  validates :number, presence: true, uniqueness: { scope: :company_id,
    message: "has already been taken for this company" }, unless: :draft?
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
end
