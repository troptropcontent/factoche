module Organization
  class CreditNote < ActiveRecord::Base
    belongs_to :original_invoice, class_name: "Organization::Invoice"
    has_one_attached :pdf

    validates :total_excl_tax_amount, numericality: { greater_than_or_equal_to: 0 }

    enum :status, {
      draft: "draft",
      published: "published"
    }, default: :draft, validate: true
  end
end
