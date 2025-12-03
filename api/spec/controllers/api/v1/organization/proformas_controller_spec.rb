require 'rails_helper'
require 'swagger_helper'
require_relative "shared_examples/an_authenticated_endpoint"
require "support/shared_contexts/organization/a_company_with_a_project_with_three_items"
require 'support/shared_contexts/organization/projects/a_company_with_an_order'

# rubocop:disable RSpec/ExampleLength
RSpec.describe Api::V1::Organization::ProformasController, type: :request do
  path '/api/v1/organization/orders/{order_id}/proformas' do
    post 'Creates an invoice' do
      tags 'Invoices'
      security [ bearerAuth: [] ]
      produces 'application/json'
      consumes 'application/json'

      parameter name: :order_id, in: :path, type: :integer, required: true
      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        required: [ :invoice_amounts ],
        properties: {
          invoice_amounts: {
            type: :array,
            items: {
              type: :object,
              required: [ :original_item_uuid, :invoice_amount ],
              properties: {
                original_item_uuid: { type: :string },
                invoice_amount: { type: :string, format: "decimal" }
              }
            }
          }
        }
      }

      let(:order_id) { 1 }
      let(:body) { }
      let(:user) { FactoryBot.create(:user) }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

      include_context 'a company with a project with three items'
      let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }

      response '200', 'successfully creates completion snapshot invoice' do
        schema Organization::Proformas::ShowDto.to_schema
        let!(:member) { FactoryBot.create(:member, user:, company:) }

        let(:order_id) { order.id }
        let(:body) { { invoice_amounts: [ { original_item_uuid: first_item.original_item_uuid, invoice_amount: "1.0" } ] } }

        it("creates an invoice, its detail and its line and returns it") do |example|
          expect { submit_request(example.metadata) }.to change(Accounting::Proforma, :count).by(1)
          .and change(Accounting::FinancialTransactionDetail, :count).by(1)
          .and change(Accounting::FinancialTransactionLine, :count).by(1)

          assert_response_matches_metadata(example.metadata)
        end

        context "when the order has a fixed amount discount" do
          # Total order amount: first_item=1, second_item=4, third_item=9, total=14€
          # Fixed discount of 2€ on total order
          let!(:discount) { FactoryBot.create(:discount, :fixed_amount, project_version: order_version, amount: 2, value: 2, position: 1, name: "Commercial discount") }
          # Invoicing 7€ which is 50% of the total (7/14)
          let(:body) { { invoice_amounts: [ { original_item_uuid: first_item.original_item_uuid, invoice_amount: "1.0" }, { original_item_uuid: second_item.original_item_uuid, invoice_amount: "4.0" }, { original_item_uuid: third_item.original_item_uuid, invoice_amount: "2.0" } ] } }

          it("creates a proforma with discount and total_excl_tax_amount equals invoice amounts minus prorated discount", :aggregate_failures) do |example|
            expect { submit_request(example.metadata) }
              .to change(Accounting::Proforma, :count).by(1)
              .and change(Accounting::FinancialTransactionDetail, :count).by(1)
              .and change(Accounting::FinancialTransactionLine, :count).by(4) # 3 charge lines + 1 discount line

            assert_response_matches_metadata(example.metadata)

            parsed_response = JSON.parse(response.body)

            # Verify discount is included in context
            expect(parsed_response.dig("result", "context", "project_version_discounts")).to be_an(Array)
            expect(parsed_response.dig("result", "context", "project_version_discounts").length).to eq(1)

            discount_data = parsed_response.dig("result", "context", "project_version_discounts", 0)
            expect(discount_data["original_discount_uuid"]).to eq(discount.original_discount_uuid)
            expect(discount_data["kind"]).to eq("fixed_amount")
            expect(discount_data["amount"]).to eq("2.0")
            expect(discount_data["name"]).to eq("Commercial discount")

            # Verify lines include both charges and discount
            lines = parsed_response.dig("result", "lines")
            expect(lines.length).to eq(4)

            charge_lines = lines.select { |line| line["kind"] == "charge" }
            discount_line = lines.find { |line| line["kind"] == "discount" }

            expect(charge_lines.length).to eq(3)
            expect(discount_line).to be_present
            expect(discount_line["holder_id"]).to eq(discount.original_discount_uuid)

            # Calculate expected values
            invoice_total = 1.0 + 4.0 + 2.0 # 7€
            order_total = 14.0 # 1 + 4 + 9
            invoice_proportion = invoice_total / order_total # 7/14 = 0.5
            prorated_discount = (2.0 * invoice_proportion).round(2) # 1€

            # Verify prorated discount on discount line
            expect(discount_line["excl_tax_amount"].to_f).to eq(-prorated_discount)

            # Verify total_excl_tax_amount = invoice_amounts - prorated_discount
            expected_total_excl_tax = invoice_total - prorated_discount # 7 - 1 = 6€
            actual_total_excl_tax = parsed_response.dig("result", "total_excl_tax_amount").to_f

            expect(actual_total_excl_tax).to eq(expected_total_excl_tax)
          end
        end

        context "when the order has a percentage discount" do
          # 10% discount on total order amount of 14€ = 1.4€
          let!(:discount) { FactoryBot.create(:discount, :percentage, project_version: order_version, value: 0.1, amount: 1.4, position: 1, name: "Volume discount") }
          # Invoicing 10.5€ which is 75% of the total (10.5/14)
          let(:body) { { invoice_amounts: [ { original_item_uuid: first_item.original_item_uuid, invoice_amount: "1.0" }, { original_item_uuid: second_item.original_item_uuid, invoice_amount: "4.0" }, { original_item_uuid: third_item.original_item_uuid, invoice_amount: "5.5" } ] } }

          it("creates a proforma with discount and total_excl_tax_amount equals invoice amounts minus prorated discount", :aggregate_failures) do |example|
            expect { submit_request(example.metadata) }
              .to change(Accounting::Proforma, :count).by(1)
              .and change(Accounting::FinancialTransactionDetail, :count).by(1)
              .and change(Accounting::FinancialTransactionLine, :count).by(4) # 3 charge lines + 1 discount line

            assert_response_matches_metadata(example.metadata)

            parsed_response = JSON.parse(response.body)

            # Verify discount is included in context
            discount_data = parsed_response.dig("result", "context", "project_version_discounts", 0)
            expect(discount_data["kind"]).to eq("percentage")
            expect(discount_data["value"]).to eq("0.1")
            expect(discount_data["amount"]).to eq("1.4")

            # Verify discount line is present
            lines = parsed_response.dig("result", "lines")
            discount_line = lines.find { |line| line["kind"] == "discount" }
            expect(discount_line).to be_present

            # Calculate expected values
            invoice_total = 1.0 + 4.0 + 5.5 # 10.5€
            order_total = 14.0
            invoice_proportion = invoice_total / order_total # 10.5/14 = 0.75
            prorated_discount = (1.4 * invoice_proportion).round(2) # 1.05€

            # Verify prorated discount on discount line
            expect(discount_line["excl_tax_amount"].to_f).to eq(-prorated_discount)

            # Verify total_excl_tax_amount = invoice_amounts - prorated_discount
            expected_total_excl_tax = invoice_total - prorated_discount # 10.5 - 1.05 = 9.45€
            actual_total_excl_tax = parsed_response.dig("result", "total_excl_tax_amount").to_f

            expect(actual_total_excl_tax).to eq(expected_total_excl_tax)
          end
        end

        context "when the order has multiple discounts" do
          # Fixed discount of 1.5€
          let!(:first_discount) { FactoryBot.create(:discount, :fixed_amount, project_version: order_version, amount: 1.5, value: 1.5, position: 1, name: "Early payment") }
          # Percentage discount of 5% on 14€ = 0.7€
          let!(:second_discount) { FactoryBot.create(:discount, :percentage, project_version: order_version, value: 0.05, amount: 0.7, position: 2, name: "Loyalty") }
          # Invoicing full amount of all items (14€ = 100% of order)
          let(:body) { { invoice_amounts: [ { original_item_uuid: first_item.original_item_uuid, invoice_amount: "1.0" }, { original_item_uuid: second_item.original_item_uuid, invoice_amount: "4.0" }, { original_item_uuid: third_item.original_item_uuid, invoice_amount: "9.0" } ] } }

          it("creates a proforma with all discounts and total_excl_tax_amount equals invoice amounts minus all prorated discounts", :aggregate_failures) do |example|
            expect { submit_request(example.metadata) }
              .to change(Accounting::Proforma, :count).by(1)
              .and change(Accounting::FinancialTransactionDetail, :count).by(1)
              .and change(Accounting::FinancialTransactionLine, :count).by(5) # 3 charge lines + 2 discount lines

            assert_response_matches_metadata(example.metadata)

            parsed_response = JSON.parse(response.body)

            # Verify both discounts are included in context
            discounts = parsed_response.dig("result", "context", "project_version_discounts")
            expect(discounts.length).to eq(2)
            expect(discounts.map { |d| d["position"] }).to contain_exactly(1, 2)

            # Verify all lines are present
            lines = parsed_response.dig("result", "lines")
            expect(lines.length).to eq(5)

            charge_lines = lines.select { |line| line["kind"] == "charge" }
            discount_lines = lines.select { |line| line["kind"] == "discount" }

            expect(charge_lines.length).to eq(3)
            expect(discount_lines.length).to eq(2)

            # Calculate expected values
            invoice_total = 1.0 + 4.0 + 9.0 # 14€
            order_total = 14.0
            invoice_proportion = invoice_total / order_total # 14/14 = 1.0 (100%)

            # Both discounts fully applied since we're invoicing 100%
            prorated_discount_1 = (1.5 * invoice_proportion).round(2) # 1.5€
            prorated_discount_2 = (0.7 * invoice_proportion).round(2) # 0.7€
            total_prorated_discounts = prorated_discount_1 + prorated_discount_2 # 2.2€

            # Verify total discount amount
            total_discount_amount = discount_lines.sum { |line| line["excl_tax_amount"].to_f.abs }
            expect(total_discount_amount).to eq(total_prorated_discounts)

            # Verify total_excl_tax_amount = invoice_amounts - total_prorated_discounts
            expected_total_excl_tax = invoice_total - total_prorated_discounts # 14 - 2.2 = 11.8€
            actual_total_excl_tax = parsed_response.dig("result", "total_excl_tax_amount").to_f

            expect(actual_total_excl_tax).to eq(expected_total_excl_tax)
          end
        end
      end

      it_behaves_like "an authenticated endpoint"

      response '401', 'unauthorized' do
        let(:order_id) { order.id }

        context "when the order does not belong to a company the user is a member of" do
          run_test!
        end
      end

      response '404', 'not_found' do
        let(:order_id) { -1 }

        context "when the order does not exists" do
          run_test!
        end
      end
    end
  end
  path '/api/v1/organization/companies/{company_id}/proformas' do
    get 'Lists invoices for an order' do
      tags 'Invoices'
      security [ bearerAuth: [] ]
      produces 'application/json'
      parameter name: :company_id, in: :path, type: :integer
      parameter name: 'order_id',
        in: :query,
        schema: {
          type: :integer
        }

      let(:order_id) { nil }
      let(:company_id) { company.id }
      let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }
      let(:user) { FactoryBot.create(:user) }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
      include_context 'a company with an order'

      response '200', 'invoices found' do
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        schema ::Organization::Proformas::IndexDto.to_schema

        context "when there are no invoices attached to the order" do
          run_test!("it returns an empty array") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response["results"]).to eq([])
          end
        end

        context "when there are invoices attached to the order" do
          before {
            Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data
          }

          run_test!("it returns the invoices") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response["results"].count).to eq(1)
            expect(parsed_response.dig("results", 0)).to include({ "number"=> "PRO-#{Time.current.year}-#{Time.current.month.to_s.rjust(2, "0")}-000001" })
          end
        end

        describe "when the company_id does not belong to a company the user is a member of" do
          let(:company_id) { FactoryBot.create(:company).id }

          before {
            Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data
          }

          run_test!("it returns an empty array") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response["results"]).to eq([])
          end
        end

        context "when order_id is provided in the query params" do
          context "when the order_id correctly belongs to an order of the company" do
            let(:order_id) { order.id }

            before do
              # another order
              another_quote = FactoryBot.create(:quote, :with_version, company: company, client: client, number: 2, bank_detail: company.bank_details.first)
              another_draft_order = FactoryBot.create(:draft_order, :with_version, company: company, client: client, original_project_version: another_quote.last_version, number: 2, bank_detail: company.bank_details.first)
              another_order = FactoryBot.create(:order, :with_version, company: company, client: client, original_project_version: another_draft_order.last_version, number: 2, bank_detail: company.bank_details.first)

              # A proforma from another order
              another_order_proforma = Organization::Proformas::Create.call(another_order.last_version.id, { invoice_amounts: [ { original_item_uuid: another_order.last_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data

              # An invoice from another order
              Accounting::Proformas::Post.call(another_order_proforma.id).data.persisted?

              # A proforma related to the order
              order_proforma = Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data

              # An invoice related to the order
              Accounting::Proformas::Post.call(order_proforma.id).data.persisted?
            end

            run_test!("it returns the filtered invoices") do
              parsed_response = JSON.parse(response.body)
              expect(parsed_response.dig("results", 0, "number")).to eq("PRO-#{Time.current.year}-#{Time.current.month.to_s.rjust(2, "0")}-000002")
              expect(parsed_response.dig("results").length).to eq(1)
            end
          end
        end
      end

      it_behaves_like "an authenticated endpoint"
    end
  end
  path '/api/v1/organization/proformas/{id}' do
    get 'Show invoice' do
      tags 'Invoices'
      security [ bearerAuth: [] ]
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer

      include_context 'a company with an order'

      let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }
      let(:proforma) { ::Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data }
      let(:id) { proforma.id }
      let(:company_id) { company.id }
      let(:user) { FactoryBot.create(:user) }
      let(:Authorization) { access_token(user) }
      include_context 'a company with a project with three items'

      response '200', 'proforma found' do
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        schema Organization::Proformas::ShowDto.to_schema

        run_test!
      end

      response '401', 'unauthorised' do
        describe "when the company is not a company the user is a member of" do
          run_test!
        end
      end

      response '404', 'not_found' do
        describe "when the proforma does not exists" do
          let(:id) { -1 }

          run_test!
        end
      end

      it_behaves_like "an authenticated endpoint"
    end

    put 'Update proforma' do
      tags 'Proformas'
      security [ bearerAuth: [] ]
      produces 'application/json'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :integer
      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        required: [ :invoice_amounts ],
        properties: {
          invoice_amounts: {
            type: :array,
            items: {
              type: :object,
              required: [ :original_item_uuid, :invoice_amount ],
              properties: {
                original_item_uuid: { type: :string },
                invoice_amount: { type: :string, format: "decimal" }
              }
            }
          }
        }
      }

      include_context 'a company with an order'

      let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }
      let!(:proforma) {
        ::Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" }, { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: "0.2" } ] }).data
      }
      let(:id) { proforma.id }
      let(:user) { FactoryBot.create(:user) }

      let(:Authorization) { "Bearer #{access_token(user)}" }
      let(:body) { { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "1" } ] } }

      response '200', 'Proforma updated' do
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        schema Organization::Proformas::ShowDto.to_schema

        it "Updates the proforma by voiding the proforma and creating a new one", :aggregate_failures do |example|
          expect { submit_request(example.metadata) }
            .to change(Accounting::Proforma, :count).by(1)
            .and change(Accounting::FinancialTransactionDetail, :count).by(1)
            .and change(Accounting::FinancialTransactionLine, :count).by(1)

          assert_response_matches_metadata(example.metadata)

          parsed_response = JSON.parse(response.body)

          expect(parsed_response.dig("result", "id")).not_to eq(proforma.id)
          expect(parsed_response.dig("result", "status")).to eq("draft")
          expect(parsed_response.dig("result", "number")).to end_with("002")
        end

        context "when the client has changed" do
          before { client.update(name: "New Client Name") }

          it "Updates the invoice details accordingly" do |example|
            submit_request(example.metadata)

            parsed_response = JSON.parse(response.body)

            expect(parsed_response.dig("result", "detail", "client_name")).to eq("New Client Name")

            assert_response_matches_metadata(example.metadata)
          end
        end
      end

      response '404', 'invoice not found' do
        describe "when the proforma does not exists" do
          let(:id) { -1 }

          run_test!
        end
      end

      response '401', 'unathorised' do
        describe "when the proforma does not belong to a company the user is a member of" do
          let(:Authorization) { "Bearer #{access_token(FactoryBot.create(:user))}" }

          run_test!
        end
      end

      response '422', 'unprocessable entity' do
        let!(:member) { FactoryBot.create(:member, user:, company:) }

        context "when the invoice is not draft" do
          before { proforma.update(status: :posted) }

          run_test!
        end

        context "when the invoice_amount would exceed the total amount allowed in the order for the item" do
          let(:body) { { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "100000" } ] } }

          run_test!
        end

        context "when the original_item_uuid does not belong to the order" do
          let(:body) { { invoice_amounts: [ { original_item_uuid: "another_id", invoice_amount: "1" } ] } }

          run_test!
        end

        context "when the params are not valid" do
          let(:body) { { invoice_amounts: [ { invoice_amount: "1" } ] } }

          run_test!
        end
      end

      it_behaves_like "an authenticated endpoint"
    end

    delete 'Voids an invoice' do
      tags 'Proformas'
      security [ bearerAuth: [] ]
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, required: true

      include_context 'a company with an order'

      let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }
      let(:proforma) {
        Organization::Proformas::Create.call(order_version.id, {
          invoice_amounts: [
            { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" }
          ]
        }).data
      }
      let(:id) { proforma.id }

      let(:user) { FactoryBot.create(:user) }
      let(:Authorization) { access_token(user) }

      response '200', 'proforma voided' do
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        schema Organization::Proformas::ShowDto.to_schema

        it "voids the proforma" do |example|
          expect {
            submit_request(example.metadata)
          }.to change { proforma.reload.status }.from("draft").to("voided")

          assert_response_matches_metadata(example.metadata)
        end
      end

      response '404', 'not found' do
        schema ApiError.schema

        context "when the proforma does not exist" do
          let(:id) { -1 }
          let!(:member) { FactoryBot.create(:member, user:, company:) }

          run_test!
        end
      end

      response '401', 'unauthorised' do
        schema ApiError.schema

        context "when the proforma does not belong to a company the user is a member of" do
          let(:Authorization) { access_token(FactoryBot.create(:user)) }

          run_test!
        end
      end

      response '422', 'unprocessable entity' do
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        schema ApiError.schema

        context "when the proforma is not in draft status" do
          before do
            proforma.update!(status: :posted)
          end

          run_test! do |response|
            expect(response.body).to include("Failed to void proforma: Cannot void a proforma that is not in draft status")
          end
        end
      end

      it_behaves_like "an authenticated endpoint"
    end

    post 'Post proforma' do
      tags 'Proformas'
      security [ bearerAuth: [] ]
      produces 'application/json'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :integer
      parameter name: :body, in: :body, schema: {
              type: :object,
              properties: {
                issue_date: { type: :string }
              }
            }

      include_context 'a company with an order'

      let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }
      let!(:proforma) {
        ::Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" }, { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: "0.2" } ] }).data
      }
      let(:id) { proforma.id }

      let(:user) { FactoryBot.create(:user) }
      let(:Authorization) { access_token(user) }
      let!(:member) { FactoryBot.create(:member, user:, company:) }

      response '200', 'invoice posted' do
        schema Organization::Proformas::ShowDto.to_schema

        it "Posts the proforma by voiding the proforma and creating a new instance of Invoice at the proforma date", :aggregate_failures do |example|
          expect { submit_request(example.metadata) }
            .to change(Accounting::Invoice, :count).by(1)
            .and change(Accounting::FinancialTransactionDetail, :count).by(1)
            .and change(Accounting::FinancialTransactionLine, :count).by(2)

          assert_response_matches_metadata(example.metadata)

          parsed_response = JSON.parse(response.body)

          expect(parsed_response.dig("result", "id")).not_to eq(proforma.id)
          expect(parsed_response.dig("result", "status")).to eq("posted")
          expect(parsed_response.dig("result", "number")).to end_with("001")
          expect(Date.parse(parsed_response.dig("result", "issue_date"))).to eq(proforma.issue_date.to_date)
        end

        context "when an issue_date is provided" do
          let(:body) { { issue_date: (Date.current - 2.days).strftime("%d-%m-%Y") } }

           it "Posts the proforma by voiding the proforma and creating a new instance of Invoice with the provided issue_date", :aggregate_failures do |example|
          expect { submit_request(example.metadata) }
            .to change(Accounting::Invoice, :count).by(1)
            .and change(Accounting::FinancialTransactionDetail, :count).by(1)
            .and change(Accounting::FinancialTransactionLine, :count).by(2)

          assert_response_matches_metadata(example.metadata)

          parsed_response = JSON.parse(response.body)

          expect(parsed_response.dig("result", "id")).not_to eq(proforma.id)
          expect(parsed_response.dig("result", "status")).to eq("posted")
          expect(parsed_response.dig("result", "number")).to end_with("001")
          expect(Date.parse(parsed_response.dig("result", "issue_date"))).to eq(Date.current - 2.days)
        end
        end
      end

      response '404', 'invoice not found' do
        context "when the proforma does not exist" do
          let(:id) { -1 }

          run_test!
        end
      end

      response '401', 'unauthorised' do
        context "when the proforma does not belogn to a company the user is a member of" do
          let(:Authorization) { access_token(FactoryBot.create(:user)) }

          run_test!
        end
      end

      response '422', 'unprocessable entity' do
        context "when the invoice is not draft" do
          before { proforma.update(status: :posted) }

          run_test!
        end
      end

      it_behaves_like "an authenticated endpoint"
    end
  end
end
# rubocop:enable RSpec/ExampleLength
