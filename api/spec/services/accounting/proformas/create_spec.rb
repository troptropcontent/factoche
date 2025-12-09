require 'rails_helper'

module Accounting
  module Proformas
    # rubocop:disable RSpec/MultipleMemoizedHelpers
    RSpec.describe Create do
      describe '.call' do
        subject(:result) { described_class.call({ company:, client:, project:, project_version:, new_invoice_items: proforma_items, issue_date:, snapshot_number: }) }
        let(:snapshot_number) { 1 }
        let(:issue_date) { Time.new(2024, 3, 20) }
        let(:company_id) { 1 }
        let(:client_id) { 1 }
        let(:proforma_items) { [ {
          original_item_uuid: project_version.dig(:items, 0, :original_item_uuid),
          invoice_amount: "125.23"
        } ] }
        let(:project_version_id) { 2 }
        let(:first_item_uuid) { "item-1" }
        let(:project) { FactoryBot.build(:accounting_project_hash, name: "Super Project", address_city: "Biarritz", address_zipcode: "64200", address_street: "24 rue des mouettes")  }
        let(:project_version) { FactoryBot.build(:accounting_project_version_hash, id: project_version_id, items: items, discounts: discounts, item_group_ids: [ 1, 2 ]) }
        let(:discounts) { [] }
        let(:items) { [
          FactoryBot.create(:accounting_project_version_item_hash, group_id: 1),
          FactoryBot.create(:accounting_project_version_item_hash, group_id: 2)
        ]}
        let(:company) { {
          id: company_id,
          name: "ACME Corp",
          registration_number: "123456789",
          address_zipcode: "75001",
          address_street: "1 rue de la Paix",
          address_city: "Paris",
          vat_number: "FR123456789",
          phone: "+33123456789",
          email: "contact@acmecorp.com",
          rcs_city: "Paris",
          rcs_number: "RCS123456",
          legal_form: "sas",
          capital_amount: 10000,
          config: {
            payment_term_days: 30,
            payment_term_accepted_methods: [ 'transfer' ],
            general_terms_and_conditions: '<h1>Condition<h1/>'
          },
          bank_detail: {
          iban: 'IBAN',
          bic: 'BIC'
        }
        } }

        let(:client) { {
          id: client_id,
          name: "Client Corp",
          registration_number: "987654321",
          address_zipcode: "75002",
          address_street: "2 avenue des Champs-Élysées",
          address_city: "Paris",
          vat_number: "FR987654321",
          phone: "+33987654321",
          email: "contact@clientcorp.com"
        } }

        before do
          FactoryBot.create(:financial_year, company_id: company[:id], start_date: issue_date.beginning_of_year, end_date: issue_date.end_of_year)
          # Create a previous proforma
          previous_posted_proforma_items = [ {
            original_item_uuid: project_version.dig(:items, 0, :original_item_uuid),
            invoice_amount: "50"
            } ]

          result = described_class.call({ company:, client:, project:, project_version:, new_invoice_items: previous_posted_proforma_items, issue_date:, snapshot_number: })

          previous_posted_proforma = result.data

          previous_posted_proforma = Accounting::Proformas::Post.call(previous_posted_proforma.id).data
        end

        context 'when successful' do
          # rubocop:disable RSpec/ExampleLength
          before do
            allow(Accounting::FinancialTransactions::GenerateAndAttachPdfJob).to receive(:perform_async)
          end

          it { is_expected.to be_success }

          it 'creates a draft proforma', :aggregate_failures do
            expect(result.data).to be_a(Proforma)

            proforma = result.data
            expect(proforma.company_id).to eq(company_id)
            expect(proforma.holder_id).to eq(project_version_id)
            expect(proforma.status).to eq("draft")
            expect(proforma.number).to eq("PRO-2024-03-000002")

            expect(proforma.context["project_name"]).to eq("Super Project")
            expect(proforma.context["project_version_number"]).to eq(1)
            expected_project_total_amount = project_version.dig(:items, 0, :quantity) * project_version.dig(:items, 0, :unit_price_amount) + project_version.dig(:items, 1, :quantity) * project_version.dig(:items, 1, :unit_price_amount)
            expect(proforma.context["project_total_amount"]).to eq(expected_project_total_amount.to_s)
            expect(proforma.context["project_version_items"]).to be_present
            expect(proforma.context["project_version_item_groups"]).to be_present
          end
          # rubocop:enable RSpec/ExampleLength

          it 'creates the relevant invoice lines', :aggregate_failures do
            proforma = result.data

            expect(proforma.lines.count).to eq(1)
            expect(proforma.lines.first.excl_tax_amount).to eq('125.23'.to_d)

            expect(proforma.lines.first.quantity).to eq("1.2523".to_d) # 125 € (invoice amount) / 100 € (unit price) => the proportional quantity required to reach the amount invoiced
          end

          # rubocop:disable RSpec/ExampleLength
          it 'creates the relevant invoice detail', :aggregate_failures do
            proforma = result.data

            expect(proforma.detail).to be_present
            expect(proforma.detail).to have_attributes(
              delivery_date: be_within(1.second).of(issue_date),
              due_date: be_within(1.second).of(issue_date + 30.days),
              seller_name: company[:name],
              seller_registration_number: company[:registration_number],
              seller_address_zipcode: company[:address_zipcode],
              seller_address_street: company[:address_street],
              seller_address_city: company[:address_city],
              seller_vat_number: company[:vat_number],
              seller_rcs_city: company[:rcs_city],
              seller_rcs_number: company[:rcs_number],
              seller_legal_form: company[:legal_form],
              seller_capital_amount: company[:capital_amount],
              payment_term_days: company[:config][:payment_term_days],
              payment_term_accepted_methods: company[:config][:payment_term_accepted_methods],
              general_terms_and_conditions: company[:config][:general_terms_and_conditions],
              client_vat_number: client[:vat_number],
              client_name: client[:name],
              client_registration_number: client[:registration_number],
              client_address_zipcode: client[:address_zipcode],
              client_address_street: client[:address_street],
              client_address_city: client[:address_city],
              delivery_name: client[:name],
              delivery_registration_number: client[:registration_number],
              delivery_address_zipcode: project[:address_zipcode],
              delivery_address_street: project[:address_street],
              delivery_address_city: project[:address_city],
              purchase_order_number: project[:po_number].to_s
            )
          end
          # rubocop:enable RSpec/ExampleLength

          #
          it 'enqueues PDF generation job' do
            proforma = result.data

            expect(Accounting::FinancialTransactions::GenerateAndAttachPdfJob)
              .to have_received(:perform_async)
              .with({ "financial_transaction_id" => proforma.id })
          end

          context "when project has discounts" do
            let(:items) { [
              FactoryBot.build(:accounting_project_version_item_hash, group_id: 1, quantity: 1, unit_price_amount: 5000),
              FactoryBot.build(:accounting_project_version_item_hash, group_id: 2, quantity: 1, unit_price_amount: 5000)
            ]} # total of the project => 5000 + 5000 => 10000
            let(:proforma_items) { [ {
              original_item_uuid: project_version.dig(:items, 0, :original_item_uuid),
              invoice_amount: "3000"
            } ] } # total of the invoice => 3000 (30% of project)
            let(:discounts) { [
              FactoryBot.build(:accounting_project_version_discount_hash, amount: 300.to_d),
              FactoryBot.build(:accounting_project_version_discount_hash, amount: 200.to_d)
            ] } # total of the discounts => 500

            it 'includes discounts in context', :aggregate_failures do
              proforma = result.data

              expect(proforma.context["project_version_discounts"]).to be_present
              expect(proforma.context["project_version_discounts"].length).to eq(2)

              first_discount_context = proforma.context["project_version_discounts"].first
              expect(first_discount_context).to include(
                "kind" => "percentage",
                "amount" => "300.0"
              )
            end

            context "when no new_invoice_discounts are provided" do
              it { is_expected.to be_success }

              # rubocop:disable RSpec/ExampleLength
              it 'creates only charge lines (no discount lines)', :aggregate_failures do
                # Discount lines are only created when discount amounts are explicitly provided for this invoice
                # Project total: 5000 + 5000 = 10000€
                # Discounts total: 500€ (300 + 200)
                # Net project total: 9500€
                # Invoice amount: 3000€

                proforma = result.data
                expect(proforma.lines.count).to eq(1) # 1 charge only, no discount lines

                charge_line = proforma.lines.charge.first
                expect(charge_line.excl_tax_amount).to eq(3000.to_d)
                expect(charge_line.quantity).to eq(0.6.to_d) # 3000€ (invoice amount) / 5000€ (unit price)
                expect(charge_line.kind).to eq("charge")

                # No discount lines since none provided for this invoice
                discount_lines = proforma.lines.discount
                expect(discount_lines.count).to eq(0)
              end
              # rubocop:enable RSpec/ExampleLength
            end

            context "when new_invoice_discounts are provided" do
              subject(:result) {
                described_class.call({
                  company:,
                  client:,
                  project:,
                  project_version:,
                  new_invoice_items: proforma_items,
                  new_invoice_discounts: [
                    { original_discount_uuid: discounts[0][:original_discount_uuid], discount_amount: 90.0 },
                    { original_discount_uuid: discounts[1][:original_discount_uuid], discount_amount: 60.0 }
                  ],
                  issue_date:,
                  snapshot_number:
                })
              }

              it { is_expected.to be_success }

              # rubocop:disable RSpec/ExampleLength
              it 'creates charge and discount lines', :aggregate_failures do
                # Project total: 5000 + 5000 = 10000€
                # Discounts total: 500€ (300 + 200)
                # Net project total: 9500€
                # Invoice amount before discount: 3000€
                # Discount amounts applied to this invoice: 90€ + 60€ = 150€
                # Invoice amount after discount: 3000 - 150 = 2850€

                proforma = result.data
                expect(proforma.lines.count).to eq(3) # 1 charge + 2 discounts

                charge_line = proforma.lines.charge.first
                expect(charge_line.excl_tax_amount).to eq(3000.to_d)
                expect(charge_line.kind).to eq("charge")

                discount_lines = proforma.lines.discount.order(:id)
                expect(discount_lines.count).to eq(2)

                first_discount = discount_lines.first
                expect(first_discount.excl_tax_amount).to eq(-90.to_d)
                expect(first_discount.kind).to eq("discount")

                second_discount = discount_lines.second
                expect(second_discount.excl_tax_amount).to eq(-60.to_d)
                expect(second_discount.kind).to eq("discount")
              end
              # rubocop:enable RSpec/ExampleLength
            end

            context "when new_invoice_discounts exceed available discount" do
              subject(:result) {
                described_class.call({
                  company:,
                  client:,
                  project:,
                  project_version:,
                  new_invoice_items: proforma_items,
                  new_invoice_discounts: [
                    { original_discount_uuid: discounts[0][:original_discount_uuid], discount_amount: 400.0 } # Exceeds 300€ total
                  ],
                  issue_date:,
                  snapshot_number:
                })
              }

              it { is_expected.to be_failure }

              it 'returns validation error', :aggregate_failures do
                expect(result.error).to be_a(StandardError)
                expect(result.error.message).to include("Total discount amount")
                expect(result.error.message).to include("would exceed the maximum allowed discount")
                expect(result.error.message).to include("300") # Total discount available
              end
            end
          end
        end

        context 'when there is an error' do
          before do
            allow(Proforma).to receive(:create!).and_raise("Database error")
          end

          it { is_expected.to be_failure }

          it 'returns a failure result', :aggregate_failures do
            expect(result.error.message).to include("Database error")
          end
        end
      end
    end
    # rubocop:enable RSpec/MultipleMemoizedHelpers
  end
end
