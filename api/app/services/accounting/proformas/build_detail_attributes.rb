module Accounting
  module Proformas
    class BuildDetailAttributes
      class << self
        def call(company, client, project_version, issue_date)
          attributes = {
              general_terms_and_conditions: company.fetch(:config).fetch(:general_terms_and_conditions),
              delivery_date: issue_date,
              payment_term_days: company.fetch(:config).fetch(:payment_term_days),
              payment_term_accepted_methods: company.fetch(:config).fetch(:payment_term_accepted_methods),
              due_date: issue_date + company.fetch(:config).fetch(:payment_term_days).days,
              seller_name: company.fetch(:name),
              seller_registration_number: company.fetch(:registration_number),
              seller_address_zipcode: company.fetch(:address_zipcode),
              seller_address_street: company.fetch(:address_street),
              seller_address_city: company.fetch(:address_city),
              seller_vat_number: company.fetch(:vat_number),
              seller_phone: company.fetch(:phone),
              seller_email: company.fetch(:email),
              seller_rcs_city: company.fetch(:rcs_city),
              seller_rcs_number: company.fetch(:rcs_number),
              seller_legal_form: company.fetch(:legal_form),
              seller_capital_amount: company.fetch(:capital_amount),
              client_vat_number: client.fetch(:vat_number),
              client_name: client.fetch(:name),
              client_registration_number: client.fetch(:registration_number),
              client_address_zipcode: client.fetch(:address_zipcode),
              client_address_street: client.fetch(:address_street),
              client_address_city: client.fetch(:address_city),
              client_phone: client.fetch(:phone),
              client_email: client.fetch(:email),
              delivery_name: client.fetch(:name),
              delivery_registration_number: client.fetch(:registration_number),
              delivery_address_zipcode: client.fetch(:address_zipcode),
              delivery_address_street: client.fetch(:address_street),
              delivery_address_city: client.fetch(:address_city),
              delivery_phone: client.fetch(:phone),
              delivery_email: client.fetch(:email),
              purchase_order_number: project_version.fetch(:id)
            }

          ServiceResult.success(attributes)
        rescue StandardError => e
          ServiceResult.failure("Failed to build invoice detail attributes: #{e.message}")
        end
      end
    end
  end
end
