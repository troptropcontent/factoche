module Accounting
  module FinancialTransactions
    class BuildCompletionSnapshotInvoiceDetailAttributes
      class << self
        def call(company, client, project_version, issue_date)
          attributes = {
              delivery_date: issue_date,
              due_date: issue_date + company.fetch(:config).fetch(:payment_term).fetch(:days).to_i.days,
              seller_name: company.fetch(:name),
              seller_registration_number: company.fetch(:registration_number),
              seller_address_zipcode: company.fetch(:address_zipcode),
              seller_address_street: company.fetch(:address_street),
              seller_address_city: company.fetch(:address_city),
              seller_vat_number: company.fetch(:vat_number),
              client_vat_number: client.fetch(:vat_number),
              client_name: client.fetch(:name),
              client_registration_number: client.fetch(:registration_number),
              client_address_zipcode: client.fetch(:address_zipcode),
              client_address_street: client.fetch(:address_street),
              client_address_city: client.fetch(:address_city),
              delivery_name: client.fetch(:name),
              delivery_registration_number: client.fetch(:registration_number),
              delivery_address_zipcode: client.fetch(:address_zipcode),
              delivery_address_street: client.fetch(:address_street),
              delivery_address_city: client.fetch(:address_city),
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
