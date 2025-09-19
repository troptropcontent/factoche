require 'rails_helper'
require 'support/shared_contexts/organization/projects/a_company_with_an_order'
require 'services/shared_examples/service_result_example'

RSpec.describe Organization::Dashboards::FetchKpiYtdTotalRevenue do
  subject(:result) { described_class.call(company_id: company.id, end_date: end_date, websocket_channel_id:) }

  include_context 'a company with an order'
  let(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }
  let!(:financial_year_last_year) { FactoryBot.create(:financial_year, company_id: company.id, start_date: financial_year.start_date.last_year, end_date: financial_year.end_date.last_year) }

  let(:first_item_unit_price_amount) { 200 }
  let(:first_item_quantity) { 3 }
  let(:second_item_unit_price_amount) { 34.99 }
  let(:second_item_quantity) { 17 }

  let(:end_date) { Time.current }
  let(:websocket_channel_id) { nil }

  describe '#call' do
    context 'when calculating revenue for current year' do
      before do
        # Create a proforma for 55 € (22 € + 33 €)
        first_proforma = Organization::Proformas::Create.call(order_version.id, {
            invoice_amounts: [
              { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: 22 },
              { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: 33 }
            ]
        }).data

        # Create an invoice for 55 € as per the proforma
        first_invoice = Accounting::Proformas::Post.call(first_proforma.id).data

        # Cancel the invoice the invoice
        Accounting::Invoices::Cancel.call(first_invoice.id).data[:credit_note]

        # Create a second proforma for 299 € ( 69 € + 230 € )
        second_proforma = Organization::Proformas::Create.call(order_version.id, {
          invoice_amounts: [
            { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: 69 },
            { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: 230 }
          ]
        }).data

        # Create a second invoice for 299 € as per the proforma
        Accounting::Proformas::Post.call(second_proforma.id).data
      end

      it_behaves_like 'a success'

      it 'returns correct YTD revenue for current year' do
        expect(result.data[:ytd_revenue_for_this_year]).to eq(299) # 55 € + 299 € - 55 €
      end
    end


    context 'when calculating revenue for previous year' do
      before do
        ##### Transactions before end_date.last_year that should be counted #####
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

        ##### Transactions after end_date.last_year that should not be counted #####
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

      it_behaves_like 'a success'

      it 'returns correct YTD revenue for last year' do
        expect(result.data[:ytd_revenue_for_last_year]).to eq(143) # 116 € + 143 € - 116 €
      end
    end

    context 'when websocket channel is provided' do
      let(:websocket_channel_id) { 'test_channel' }
      let(:action_cable) { class_double(ActionCable::Server::Broadcasting) }

      before do
        allow(ActionCable.server).to receive(:broadcast)
      end

      it 'broadcasts the results to the websocket channel' do
        result

        expect(ActionCable.server).to have_received(:broadcast).with(
          websocket_channel_id,
          {
            "type" => "KpiTotalRevenueGenerated",
            "data" => {
              "ytd_revenue_for_this_year" => "0.0",
              "ytd_revenue_for_last_year" => "0.0"
            }
          }
        )
      end
    end
  end
end
