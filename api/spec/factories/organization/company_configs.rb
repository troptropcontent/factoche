FactoryBot.define do
  factory :company_config, class: 'Organization::CompanyConfig' do
    company { }
    settings { {
      payment_term: {
        days: 30,
        methods: [ "transfer" ]
      }
    }}
  end
end
