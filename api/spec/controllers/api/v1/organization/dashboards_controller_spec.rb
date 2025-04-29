require 'rails_helper'
require 'swagger_helper'
require_relative "shared_examples/an_authenticated_endpoint"
require 'support/shared_contexts/organization/projects/a_company_with_an_order'

RSpec.describe Api::V1::Organization::DashboardsController, type: :request do
  path '/api/v1/organization/companies/{company_id}/dashboard' do
    get 'Get company\'s dashboard data' do
      tags 'Dashboard'
      security [ bearerAuth: [] ]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :company_id, in: :path, type: :integer

      include_context 'a company with an order'

      # Setup items to have a total project version of 200 * 3 + 34.99 * 17 + 200 + 10 = 3 194.83 €
      let(:first_item_unit_price_amount) { 200 }
      let(:first_item_quantity) { 3 }
      let(:second_item_unit_price_amount) { 34.99 }
      let(:second_item_quantity) { 17 }
      let(:third_item_unit_price_amount) { 200 }
      let(:third_item_quantity) { 10 }

      let(:user) { FactoryBot.create(:user) }
      let!(:member) { FactoryBot.create(:member, user:, company:) }
      let(:Authorization) { access_token(user) }

      let(:company_id) { company.id }

      let(:end_date) { Time.current }

      response '200', 'client created' do
        schema ::Organization::Dashboards::ShowDto.to_schema

        describe "kpis" do
          describe "ytd_total_revenues" do
            before do
              ##### Transactions before end_date that should be counted in ytd_total_revenues.this_year #####
              # Create a proforma for 55 € (22 € + 33 €)
              first_proforma = Organization::Proformas::Create.call(
                order_version.id,
                {
                  invoice_amounts: [
                    { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: 22 },
                    { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: 33 }
                  ]
                }
              ).data

              # Create an invoice for 55 € as per the proforma
              first_invoice = Accounting::Proformas::Post.call(first_proforma.id).data

              # Cancel the invoice the invoice
              Accounting::Invoices::Cancel.call(first_invoice.id).data[:credit_note]

              # Create a second proforma for 299 € ( 69 € + 230 € )
              second_proforma = Organization::Proformas::Create.call(
                order_version.id,
                {
                  invoice_amounts: [
                    { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: 69 },
                    { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: 230 }
                  ]
                }
              ).data

              # Create a second invoice for 299 € as per the proforma
              Accounting::Proformas::Post.call(second_proforma.id).data

              ##### Transactions before end_date.last_year that should be counted in ytd_total_revenues.last_year #####
              # Create a proforma for 116 € (17 € + 99 €) with a date before end_date.last_year
              first_proforma = Organization::Proformas::Create.call(
                order_version.id,
                {
                  invoice_amounts: [
                    { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: 17 },
                    { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: 99 }
                  ]
                },
                end_date.last_year - 2.days
              ).data

              # Create an invoice for 116 € as per the proforma with a date before end_date.last_year
              first_invoice = Accounting::Proformas::Post.call(
                first_proforma.id,
                end_date.last_year - 2.days
              ).data

              # Cancel the invoice the invoice
              Accounting::Invoices::Cancel.call(
                first_invoice.id,
                end_date.last_year - 2.days
              ).data[:credit_note]

              # Create a second proforma for 143 € ( 33 € + 110 € ) with a date before end_date.last_year
              second_proforma = Organization::Proformas::Create.call(
                order_version.id,
                {
                  invoice_amounts: [
                    { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: 33 },
                    { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: 110 }
                  ]
                },
                end_date.last_year - 2.days
              ).data

              # Create a second invoice for 143 € as per the proforma with a date before end_date.last_year
              Accounting::Proformas::Post.call(
                second_proforma.id,
                end_date.last_year - 2.days
              ).data

              ##### Transactions after end_date.last_year that should not be counted in ytd_total_revenues.last_year #####
              # Create a proforma for 55 € (22 € + 33 €) with a date after end_date.last_year
              first_proforma = Organization::Proformas::Create.call(
                order_version.id,
                {
                  invoice_amounts: [
                    { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: 22 },
                    { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: 33 }
                  ]
                },
                end_date.last_year + 2.days
              ).data

              # Create an invoice for 55 € as per the proforma with a date after end_date.last_year
              first_invoice = Accounting::Proformas::Post.call(
                first_proforma.id,
                end_date.last_year + 2.days
              ).data

              # Cancel the invoice the invoice
              Accounting::Invoices::Cancel.call(
                first_invoice.id,
                end_date.last_year + 2.days
              ).data[:credit_note]

              # Create a second proforma for 299 € ( 69 € + 230 € ) with a date after end_date.last_year
              second_proforma = Organization::Proformas::Create.call(
                order_version.id,
                {
                  invoice_amounts: [
                    { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: 69 },
                    { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: 230 }
                  ]
                },
                end_date.last_year + 2.days
              ).data

              # Create a second invoice for 299 € as per the proforma with a date after end_date.last_year
              Accounting::Proformas::Post.call(
                second_proforma.id,
                end_date.last_year + 2.days
              ).data
            end

            run_test!("It returns the total revenues YTD (Year-to-Date)") do |response|
              parsed_response = JSON.parse(response.body)
              expect(parsed_response.dig("result", "kpis", "ytd_total_revenues", "this_year")).to eq("299.0")
              expect(parsed_response.dig("result", "kpis", "ytd_total_revenues", "last_year")).to eq("143.0")
            end

            describe "real_time_broadcast" do
              it "broadcasts to the company notifications channel" do |example|
                allow(ActionCable.server).to receive(:broadcast)

                submit_request(example.metadata)
                assert_response_matches_metadata(example.metadata)

                expect(ActionCable.server).to have_received(:broadcast).with(company.websocket_channel, {
                  "type" => "KpiTotalRevenueGenerated",
                  "data" => {
                    "ytd_revenue_for_this_year"=> "299.0",
                    "ytd_revenue_for_last_year"=> "143.0"
                  }
                })
              end
            end
          end

          describe "average_orders_completion_percentage" do
            before do
              # Create an invoice to impact the average_orders_completion_percentage
              proforma = Organization::Proformas::Create.call(
                order.last_version.id,
                {
                  invoice_amounts: [
                    { original_item_uuid: order_version.items.third.original_item_uuid, invoice_amount: 1500 }
                  ]
                }
              ).data

              # Create an invoice for 1500 € as per the proforma
              Accounting::Proformas::Post.call(proforma.id).data

              # After this the average_orders_compeltion_percentage should equal 1 500 (the total of the invoices) / 3 194.83 (the total of the order version) => 0.47
            end

            run_test!("It returns the total revenues YTD (Year-to-Date)") do |response|
              parsed_response = JSON.parse(response.body)
              parsed_average_orders_compeltion_percentage = BigDecimal(parsed_response.dig("result", "kpis", "average_orders_completion_percentage"))
              expect(parsed_average_orders_compeltion_percentage).to eq(0.47)
            end

            describe "real_time_broadcast" do
              it "broadcasts to the company notifications channel" do |example|
                allow(ActionCable.server).to receive(:broadcast)

                submit_request(example.metadata)
                assert_response_matches_metadata(example.metadata)

                expect(ActionCable.server).to have_received(:broadcast).with(company.websocket_channel, {
                  "type" => "KpiAverageOrderCompletionGenerated",
                  "data" => 0.47
                })
              end
            end
          end
        end
      end

      it_behaves_like "an authenticated endpoint"
    end
  end
end
