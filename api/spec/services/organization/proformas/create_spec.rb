require "rails_helper"
require "support/shared_contexts/organization/a_company_with_a_project_with_three_items"
require 'services/shared_examples/service_result_example'
require 'support/shared_contexts/organization/projects/a_company_with_an_order'
module Organization
  module Proformas
    RSpec.describe Create do
      # rubocop:disable RSpec/MultipleMemoizedHelpers
      describe ".call" do
        subject(:result) { described_class.call(order_version_id, params) }

        include_context 'a company with an order'
        let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }

        let(:order_version_id) { order_version.id }
        let(:base_params) { {
            invoice_amounts: [
              { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: 99 },
              { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: 20 }
            ]
          }}
        let(:params) { base_params }
        let("first_item_unit_price_amount") { 200 } # 200 €
        let("first_item_quantity") { 3 } # => total possible amount 3 * 200 € = 600 €
        let("second_item_unit_price_amount") { 50 } # 50 €
        let("second_item_quantity") { 10 } # => total possible amount 10 * 50 € = 500 €

        context "when all validations pass" do
          it { is_expected.to be_success }

          it "calls the accounting service with correct arguments", :aggregate_failures do
            allow(Accounting::Proformas::Create).to receive(:call)

            result

            expect(Accounting::Proformas::Create).to have_received(:call) do |company_hash, client_hash, project_hash, project_version_hash, amounts, issue_date|
              expect(company_hash[:id]).to eq(company.id)
              expect(client_hash[:id]).to eq(client.id)
              expect(client_hash[:name]).to eq(client.name)
              expect(project_hash[:name]).to eq(order.name)
              expect(project_version_hash[:id]).to eq(order_version.id)
              expect(amounts).to match_array(params[:invoice_amounts])
              expect(issue_date).to be_within(5).of(Time.now)
            end
          end

          context "when an issue_date is provided" do
            let(:params) {
                base_params.merge({ issue_date: "2025-09-24" })
            }

            it { is_expected.to be_success }

            it "calls the accounting service with correct arguments", :aggregate_failures do
              allow(Accounting::Proformas::Create).to receive(:call)

              result

              expect(Accounting::Proformas::Create).to have_received(:call) do |company_hash, client_hash, project_hash, project_version_hash, amounts, issue_date|
                expect(company_hash[:id]).to eq(company.id)
                expect(client_hash[:id]).to eq(client.id)
                expect(client_hash[:name]).to eq(client.name)
                expect(project_hash[:name]).to eq(order.name)
                expect(project_version_hash[:id]).to eq(order_version.id)
                expect(amounts).to match_array(params[:invoice_amounts])
                expect(issue_date).to eq(Date.parse("2025-09-24"))
              end
            end
          end
        end

        context "when invoice amounts exceed item limits" do
          let(:params) do
            {
              invoice_amounts: [
                { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "700.00" } # Exceeds total amount (3 * 200 € = 600 €)
              ]
            }
          end

          it { is_expected.to be_failure }

          it "returns a failure result" do
            expect(result.error.message).to include("Invoice amount would exceed item total amount")
          end
        end

        context "when invalid item UUID is provided" do
          let(:params) do
            {
              invoice_amounts: [
                { original_item_uuid: "non-existent-uuid", invoice_amount: "50.00" }
              ]
            }
          end

          it { is_expected.to be_failure }

          it "returns a failure result" do
            expect(result.error.message).to include("All invoice amounts must reference items that exist")
          end
        end

        context "when params are invalid" do
          let(:params) { { invoice_amounts: [] } }

          it { is_expected.to be_failure }

          it "returns a failure result" do
            expect(result.error.message).to include("invoice_amounts=>[\"must be filled\"]")
          end
        end

        context "when accounting service fails" do
          before do
            allow(Accounting::Proformas::Create).to receive(:call)
              .and_return(ServiceResult.failure("Accounting service error"))
          end

          it { is_expected.to be_failure }

          it "returns a failure result" do
            expect(result.error.message).to include("Accounting service error")
          end
        end
      end
      # rubocop:enable RSpec/MultipleMemoizedHelpers
    end
  end
end
