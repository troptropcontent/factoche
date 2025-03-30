module Organization
  module Companies
    class UpdateContract < Dry::Validation::Contract
      params do
        optional(:name).filled(:string)
        optional(:registration_number).filled(:string)
        optional(:email).filled(:string)
        optional(:phone).filled(:string)
        optional(:address_city).filled(:string)
        optional(:address_street).filled(:string)
        optional(:address_zipcode).filled(:string)
        optional(:legal_form).filled(:string)
        optional(:rcs_city).filled(:string)
        optional(:rcs_number).filled(:string)
        optional(:vat_number).filled(:string)
        optional(:capital_amount).filled(:decimal)
        optional(:configs).value(:hash) do
          optional(:general_terms_and_conditions).filled(:string)
          optional(:default_vat_rate).filled(:decimal)
          optional(:payment_term_days).filled(:integer)
          optional(:payment_term_accepted_methods).filled(:array)
        end
      end
    end
  end
end
