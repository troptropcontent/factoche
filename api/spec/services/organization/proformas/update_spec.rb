require "rails_helper"
require "support/shared_contexts/organization/a_company_with_a_project_with_three_items"
require 'services/shared_examples/service_result_example'
require 'support/shared_contexts/organization/projects/a_company_with_an_order'
module Organization
  module Proformas
    RSpec.describe Update do
      # rubocop:disable RSpec/MultipleMemoizedHelpers
      describe ".call" do
        subject(:result) { described_class.call(proforma_id, params) }

        include_context 'a company with an order'

        let(:proforma_id) { proforma.id }
        let("first_item_unit_price_amount") { 200 } # 200 €
        let("first_item_quantity") { 3 } # => total possible amount 3 * 200 € = 600 €
        let("second_item_unit_price_amount") { 50 } # 50 €
        let("second_item_quantity") { 10 } # => total possible amount 10 * 50 € = 500 €

        let(:proforma) {
          Create.call(order_version.id, {
            invoice_amounts: [
              { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: 99 },
              { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: 20 }
            ]
          }).data
        }

        let(:params) do
          {
            invoice_amounts: [
              { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: 2.00 },
              { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: 3.00 }
            ]
          }
        end

        context "when all validations pass" do
          it { is_expected.to be_success }

          it "calls the accounting service with correct arguments", :aggregate_failures do
            allow(Accounting::Proformas::Update).to receive(:call).and_return(ServiceResult.success(proforma))

            result

            expect(Accounting::Proformas::Update).to have_received(:call) do |proforma_id, company_hash, client_hash, project_hash, project_version_hash, amounts|
              expect(proforma_id).to eq(proforma.id)
              expect(company_hash[:id]).to eq(company.id)
              expect(client_hash[:name]).to eq(client.name)
              expect(project_hash[:name]).to eq(order.name)
              expect(project_version_hash[:id]).to eq(order_version.id)
              expect(amounts).to match_array(params[:invoice_amounts])
            end
          end
        end

        context "when invoice is not in draft status" do
          before do
            proforma.update!(status: :posted)
          end

          it { is_expected.to be_failure }

          it "returns a failure result" do
            expect(result.error.message).to include("Cannot update proforma that is not in draft status")
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
            allow(Accounting::Proformas::Update).to receive(:call)
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
