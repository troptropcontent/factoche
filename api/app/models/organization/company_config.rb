module Organization
  class CompanyConfig < ApplicationRecord
    DEFAULT_SETTINGS = {
      "payment_term" => {
        "days" => 30,
        "accepted_methods"=> [ "transfer" ]
      },
      "vat_rate"=> "0.20"
    }.freeze

    ALLOWED_PAYMENT_METHODS = [ "transfer", "cash", "card" ].freeze

    validates :payment_term_days, presence: true, numericality: { only_integer: true }
    validate :only_allowed_payment_terms
    validates :payment_term_accepted_methods, presence: true
    validates :default_vat_rate, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 1 }
    validates :general_terms_and_conditions, presence: true

    belongs_to :company, class_name: "Organization::Company"

    private

  def only_allowed_payment_terms
    if payment_term_accepted_methods.present?
      invalid_methods = payment_term_accepted_methods - ALLOWED_PAYMENT_METHODS
      if invalid_methods.any?
        errors.add(:payment_term_accepted_methods, "contains invalid methods: #{invalid_methods.join(', ')}")
      end
    end
  end
  end
end
