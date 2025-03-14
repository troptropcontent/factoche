require "rails_helper"
require "support/shared_contexts/organization/a_company_with_a_project_with_three_items"

module Organization
  module Invoices
    RSpec.describe Update do
      # rubocop:disable RSpec/MultipleMemoizedHelpers
      describe ".call" do
        subject(:result) { described_class.call(invoice.id, params) }

        include_context 'a company with a project with three items'

        let("first_item_unit_price_cents") { 20000 } # 200 €
        let("first_item_quantity") { 3 } # => total possible amount 3 * 200 € = 600 €
        let("second_item_unit_price_cents") { 5000 } # 50 €
        let("second_item_quantity") { 10 } # => total possible amount 10 * 50 € = 500 €

        let(:invoice) { Create.call(project_version.id, {
          invoice_amounts: [
            { original_item_uuid: first_item.original_item_uuid, invoice_amount: 99 },
            { original_item_uuid: second_item.original_item_uuid, invoice_amount: 20 }
          ]
        }).data }

        let(:params) do
          {
            invoice_amounts: [
              { original_item_uuid: first_item.original_item_uuid, invoice_amount: 2.00 },
              { original_item_uuid: second_item.original_item_uuid, invoice_amount: 3.00 }
            ]
          }
        end

        context "when all validations pass" do
          it { is_expected.to be_success }

          it "calls the accounting service with correct arguments", :aggregate_failures do
            allow(Accounting::Invoices::Update).to receive(:call).and_return(ServiceResult.success(invoice))

            result

            expect(Accounting::Invoices::Update).to have_received(:call) do |invoice_id, company_hash, client_hash, project_hash, project_version_hash, amounts|
              expect(invoice_id).to eq(invoice.id)
              expect(company_hash[:id]).to eq(company.id)
              expect(client_hash[:name]).to eq(client.name)
              expect(project_hash[:name]).to eq(project.name)
              expect(project_version_hash[:id]).to eq(project_version.id)
              expect(amounts).to match_array(params[:invoice_amounts])
            end
          end
        end

        context "when invoice is not in draft status" do
          before do
            invoice.update!(status: :posted, number: "INV-2024-00001")
          end

          it { is_expected.to be_failure }

          it "returns a failure result" do
            expect(result.error).to include("Cannot update invoice that is not in draft status")
          end
        end

        context "when invoice amounts exceed item limits" do
          let(:params) do
            {
              invoice_amounts: [
                { original_item_uuid: first_item.original_item_uuid, invoice_amount: "700.00" } # Exceeds total amount (3 * 200 € = 600 €)
              ]
            }
          end

          it { is_expected.to be_failure }

          it "returns a failure result" do
            expect(result.error).to include("Invoice amount would exceed item total amount")
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
            expect(result.error).to include("All invoice amounts must reference items that exist")
          end
        end

        context "when params are invalid" do
          let(:params) { { invoice_amounts: [] } }

          it { is_expected.to be_failure }

          it "returns a failure result" do
            expect(result.error).to include("Invalid completion snapshot invoice parameters")
          end
        end

        context "when accounting service fails" do
          before do
            allow(Accounting::Invoices::Update).to receive(:call)
              .and_return(ServiceResult.failure("Accounting service error"))
          end

          it { is_expected.to be_failure }

          it "returns a failure result" do
            expect(result.error).to include("Accounting service error")
          end
        end
      end
      # rubocop:enable RSpec/MultipleMemoizedHelpers
    end
  end
end
