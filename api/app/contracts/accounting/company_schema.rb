module Accounting
  CompanySchema = Dry::Schema.Params do
    required(:id).filled(:integer)
    required(:name).filled(:string)
    required(:registration_number).filled(:string)
    required(:address_zipcode).filled(:string)
    required(:address_street).filled(:string)
    required(:address_city).filled(:string)
    required(:vat_number).filled(:string)
    required(:phone).filled(:string)
    required(:email).filled(:string)
    required(:rcs_city).filled(:string)
    required(:rcs_number).filled(:string)
    required(:legal_form).filled(:string)
    required(:capital_amount).filled(:decimal)
    required(:config).value(:hash) do
      required(:general_terms_and_conditions).filled(:string)
      required(:payment_term_days).filled(:integer)
      required(:payment_term_accepted_methods).array(:string)
    end
    required(:bank_detail).value(:hash) do
      required(:iban).filled(:string)
      required(:bic).filled(:string)
    end
  end
end
