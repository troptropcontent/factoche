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
      let(:first_item_quantity)          { 3 }
      let(:second_item_unit_price_amount) { 34.99 }
      let(:second_item_quantity)         { 17 }
      let(:third_item_unit_price_amount) { 200 }
      let(:third_item_quantity)          { 10 }

      let(:user)         { FactoryBot.create(:user) }
      let!(:member)      { FactoryBot.create(:member, user:, company:) }
      let(:Authorization) { access_token(user) }

      let(:company_id) { company.id }
      let(:end_date)   { Time.current }

      response '200', 'client created' do
        schema ::Organization::Dashboards::ShowDto.to_schema

        shared_examples "it broadcasts to the websocket channel" do |type:, data:|
          it "broadcasts to the company notifications channel" do |example|
            allow(ActionCable.server).to receive(:broadcast)
            submit_request(example.metadata)
            assert_response_matches_metadata(example.metadata)

            expect(ActionCable.server).to have_received(:broadcast).with(
              company.websocket_channel,
              { 'type' => type, 'data' => data }
            )
          end
        end

        describe "kpis" do
          describe "ytd_total_revenues" do
            before do
              # Transactions before end_date that should be counted in ytd_total_revenues.this_year
              first_proforma = Organization::Proformas::Create.call(
                order_version.id,
                {
                  invoice_amounts: [
                    { original_item_uuid: order_version.items.first.original_item_uuid,  invoice_amount: 22 },
                    { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: 33 }
                  ]
                }
              ).data
              first_invoice = Accounting::Proformas::Post.call(first_proforma.id).data
              Accounting::Invoices::Cancel.call(first_invoice.id).data[:credit_note]

              second_proforma = Organization::Proformas::Create.call(
                order_version.id,
                {
                  invoice_amounts: [
                    { original_item_uuid: order_version.items.first.original_item_uuid,  invoice_amount: 69 },
                    { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: 230 }
                  ]
                }
              ).data
              Accounting::Proformas::Post.call(second_proforma.id).data

              # Transactions before end_date.last_year that should be counted in ytd_total_revenues.last_year
              first_proforma = Organization::Proformas::Create.call(
                order_version.id,
                {
                  invoice_amounts: [
                    { original_item_uuid: order_version.items.first.original_item_uuid,  invoice_amount: 17 },
                    { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: 99 }
                  ]
                },
                end_date.last_year - 2.days
              ).data
              first_invoice = Accounting::Proformas::Post.call(
                first_proforma.id,
                end_date.last_year - 2.days
              ).data
              Accounting::Invoices::Cancel.call(
                first_invoice.id,
                end_date.last_year - 2.days
              ).data[:credit_note]

              second_proforma = Organization::Proformas::Create.call(
                order_version.id,
                {
                  invoice_amounts: [
                    { original_item_uuid: order_version.items.first.original_item_uuid,  invoice_amount: 33 },
                    { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: 110 }
                  ]
                },
                end_date.last_year - 2.days
              ).data
              Accounting::Proformas::Post.call(
                second_proforma.id,
                end_date.last_year - 2.days
              ).data

              # Transactions after end_date.last_year that should not be counted in ytd_total_revenues.last_year
              first_proforma = Organization::Proformas::Create.call(
                order_version.id,
                {
                  invoice_amounts: [
                    { original_item_uuid: order_version.items.first.original_item_uuid,  invoice_amount: 22 },
                    { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: 33 }
                  ]
                },
                end_date.last_year + 2.days
              ).data
              first_invoice = Accounting::Proformas::Post.call(
                first_proforma.id,
                end_date.last_year + 2.days
              ).data
              Accounting::Invoices::Cancel.call(
                first_invoice.id,
                end_date.last_year + 2.days
              ).data[:credit_note]

              second_proforma = Organization::Proformas::Create.call(
                order_version.id,
                {
                  invoice_amounts: [
                    { original_item_uuid: order_version.items.first.original_item_uuid,  invoice_amount: 69 },
                    { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: 230 }
                  ]
                },
                end_date.last_year + 2.days
              ).data
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

                expect(ActionCable.server).to have_received(:broadcast).with(
                  company.websocket_channel,
                  {
                    "type" => "KpiTotalRevenueGenerated",
                    "data" => {
                      "ytd_revenue_for_this_year" => "299.0",
                      "ytd_revenue_for_last_year" => "143.0"
                    }
                  }
                )
              end
            end
          end

          describe "average_orders_completion_percentage" do
            before do
              proforma = Organization::Proformas::Create.call(
                order.last_version.id,
                {
                  invoice_amounts: [
                    { original_item_uuid: order_version.items.third.original_item_uuid, invoice_amount: 1500 }
                  ]
                }
              ).data
              Accounting::Proformas::Post.call(proforma.id).data
            end

            run_test!("It returns the total revenues YTD (Year-to-Date)") do |response|
              parsed_response = JSON.parse(response.body)
              parsed_average_orders_compeltion_percentage = BigDecimal(
                parsed_response.dig("result", "kpis", "average_orders_completion_percentage")
              )
              expect(parsed_average_orders_compeltion_percentage).to eq(0.47)
            end

            describe "real_time_broadcast" do
              it "broadcasts to the company notifications channel" do |example|
                allow(ActionCable.server).to receive(:broadcast)
                submit_request(example.metadata)
                assert_response_matches_metadata(example.metadata)

                expect(ActionCable.server).to have_received(:broadcast).with(
                  company.websocket_channel,
                  {
                    "type" => "KpiAverageOrderCompletionGenerated",
                    "data" => 0.47
                  }
                )
              end
            end
          end

          describe "orders_details" do
            before do
              proforma = Organization::Proformas::Create.call(
                order.last_version.id,
                {
                  invoice_amounts: [
                    { original_item_uuid: order_version.items.first.original_item_uuid,  invoice_amount: (order_version.items.first.quantity * order_version.items.first.unit_price_amount).round(2) },
                    { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: (order_version.items.second.quantity * order_version.items.second.unit_price_amount).round(2) },
                    { original_item_uuid: order_version.items.third.original_item_uuid,  invoice_amount: (order_version.items.third.quantity * order_version.items.third.unit_price_amount).round(2) }
                  ]
                }
              ).data

              # Create an invoice for the proforma
              Accounting::Proformas::Post.call(proforma.id).data

              # After this the order will be completed as 100 % will be invoiced
            end

            run_test!("It returns the correct orders details") do |response|
              parsed_response = JSON.parse(response.body)
              expect(parsed_response.dig("result", "kpis", "orders_details", "completed_orders_count")).to eq(1)
              expect(parsed_response.dig("result", "kpis", "orders_details", "not_completed_orders_count")).to eq(0)
            end

            describe "real_time_broadcast" do
              it "broadcasts to the company notifications channel" do |example|
                allow(ActionCable.server).to receive(:broadcast)
                submit_request(example.metadata)
                assert_response_matches_metadata(example.metadata)

                expect(ActionCable.server).to have_received(:broadcast).with(
                  company.websocket_channel,
                  {
                    'type' => 'KpiOrdersDetailsGenerated',
                    'data' => {
                      "completed_orders_count"    => 1,
                      "not_completed_orders_count" => 0
                    }
                  }
                )
              end
            end
          end
        end

        describe "charts_data" do
          describe "monthly_revenues" do
            context "when there is no invoices recorded for the year" do
            end

            context "when there is invoices recorded this year" do
              before do
                # Create an invoice of 20 € on january 1 of this year
                proforma = Organization::Proformas::Create.call(
                  order.last_version.id,
                  {
                    invoice_amounts: [
                      { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: 20 }
                    ]
                  }
                ).data
                Accounting::Proformas::Post.call(proforma.id, DateTime.new(Time.current.year, 1, 1)).data
              end

              run_test!("It returns the correct orders details") do |response|
                parsed_response = JSON.parse(response.body)
                expect(parsed_response.dig("result", "charts_data", "monthly_revenues")).to eq({
                  "january"   => "20.0",
                  "february"  => nil,
                  "march"     => nil,
                  "april"     => nil,
                  "may"       => nil,
                  "june"      => nil,
                  "july"      => nil,
                  "august"    => nil,
                  "september" => nil,
                  "october"   => nil,
                  "november"  => nil,
                  "december"  => nil
                })
              end

              it_behaves_like "it broadcasts to the websocket channel",
                            type: "GraphDataMonthlyRevenuesGenerated",
                            data: {
                              "january"   => 20.0,
                              "february"  => nil,
                              "march"     => nil,
                              "april"     => nil,
                              "may"       => nil,
                              "june"      => nil,
                              "july"      => nil,
                              "august"    => nil,
                              "september" => nil,
                              "october"   => nil,
                              "november"  => nil,
                              "december"  => nil
                            }
            end
          end

          describe "revenue_by_client" do
            context "when there is no revenues recorded" do
              run_test!("It shoudl return an empty array") do
                expect(JSON.parse(response.body).dig("result", "charts_data", "revenue_by_client")).to eq([])
              end
            end

            context "when there is revenues recorded" do
              before do
                # Create an invoice
                first_proforma = Organization::Proformas::Create.call(
                  order.last_version.id,
                  {
                    invoice_amounts: [
                      { original_item_uuid: order.last_version.items.first.original_item_uuid, invoice_amount: 123.99 }
                    ]
                  }
                ).data
                Accounting::Proformas::Post.call(first_proforma.id)
              end

              run_test!("It shoudl return an empty array") do
                expect(JSON.parse(response.body).dig("result", "charts_data", "revenue_by_client")).to eq([ { "client_id"=>order.client_id, "revenue"=>"123.99" } ])
              end

              it "broadcasts to the company notifications channel" do |example|
                allow(ActionCable.server).to receive(:broadcast)
                submit_request(example.metadata)
                assert_response_matches_metadata(example.metadata)

                expect(ActionCable.server).to have_received(:broadcast).with(
                  company.websocket_channel,
                  { 'type' => "GraphDataRevenueByClientsGenerated", 'data' => [ { client_id: order.client_id, revenue: 123.99 } ] }
                )
              end
            end
          end

          describe "order_completion_percentages" do
            context "when there is no revenues recorded" do
              run_test!("It shoudl return an empty array") do
                expect(JSON.parse(response.body).dig("result", "charts_data", "revenue_by_client")).to eq([])
              end
            end

            context "when there is revenues recorded" do
              before do
                first_proforma = Organization::Proformas::Create.call(
                  order.last_version.id,
                  {
                    invoice_amounts: [
                      { original_item_uuid: order.last_version.items.first.original_item_uuid, invoice_amount: 600 },
                      { original_item_uuid: order.last_version.items.third.original_item_uuid, invoice_amount: 2000 }
                    ]
                  }
                ).data
                Accounting::Proformas::Post.call(first_proforma.id)
              end

              run_test!("It shoudl return an empty array") do
                expect(JSON.parse(response.body).dig("result", "charts_data", "order_completion_percentages")).to eq(
                  [
                    {
                      "id"=>order.id,
                      "name"=>order.name,
                      "order_total_amount"=>"3194.83",
                      "invoiced_total_amount"=>"2600.0",
                      "completion_percentage" => "0.81"
                    }
                  ]
                )
              end

              it "broadcasts to the company notifications channel" do |example|
                allow(ActionCable.server).to receive(:broadcast)

                submit_request(example.metadata)
                assert_response_matches_metadata(example.metadata)

                expect(ActionCable.server).to have_received(:broadcast).with(
                  company.websocket_channel,
                  {
                    'type' => 'GraphDataOrderCompletionPercentagesGenerated',
                    'data' => [
                      {
                        id: order.id,
                        name: order.name,
                        order_total_amount: 3194.83,
                        invoiced_total_amount: 2600.0,
                        completion_percentage: 0.81
                      }
                    ]
                  }
                )
              end
            end
          end
        end
      end

      it_behaves_like "an authenticated endpoint"
    end
  end
end
