module Organization
  module CompanyConfigs
    class ExtendedDto < OpenApiDto
        field "default_vat_rate", :decimal
        field "payment_term_days", :integer
        field "payment_term_accepted_methods", :array, subtype: :string
        field "general_terms_and_conditions", :string
    end
  end
end
