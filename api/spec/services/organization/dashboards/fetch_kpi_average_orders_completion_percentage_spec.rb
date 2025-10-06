require 'rails_helper'
require 'support/shared_contexts/organization/projects/a_company_with_an_order'

RSpec.describe Organization::Dashboards::FetchKpiAverageOrdersCompletionPercentage do
  subject(:result) { described_class.call(company_id:, end_date:, websocket_channel_id:) }

  include_context 'a company with an order'

  # Setup items to have a project version total equal to (200 * 3) + (35 * 17) + (60 * 2) = 1 315 €
  let(:first_item_unit_price_amount) { 200 }
  let(:first_item_quantity) { 3 }
  let(:second_item_unit_price_amount) { 35 }
  let(:second_item_quantity) { 17 }
  let(:third_item_unit_price_amount) { 60 }
  let(:third_item_quantity) { 2 }

  let(:another_quote_params) do
    # Setup items to have a project version total equal to 1 000 * 1 = 1 000 €
    {
      name: "New windows in Biarritz",
      description: "A brand new set of windows for the police station",
      po_number: "PO654321",
      retention_guarantee_rate: 0.05,
      address_street: "10 Rue de la Paix",
      address_zipcode: "75002",
      address_city: "Paris",
      items: [
        {
          name: "Screws",
          quantity: 1_000,
          unit: "U",
          unit_price_amount: 1.0,
          position: 1,
          tax_rate: 0.2
        }
      ],
      groups: []
    }
  end

  let(:another_quote) do
    Organization::Quotes::Create.call(company.id, client.id, company.bank_details.last.id, another_quote_params).data
  end

  let(:another_draft_order) do
    Organization::Quotes::ConvertToDraftOrder.call(another_quote.id).data
  end

  let!(:another_order) do
    Organization::DraftOrders::ConvertToOrder.call(another_draft_order.id).data
  end

  let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id, start_date: end_date.beginning_of_year, end_date: end_date.end_of_year) }
  let(:end_date) { Time.current }
  let(:company_id) { company.id }
  let(:websocket_channel_id) { nil }

  describe '#call' do
    context 'when there is no invoices recorded for the orders' do
      it 'returns 0' do
        expect(result.data).to eq(0.0)
      end
    end

    context 'when there is invoices recorded for the orders' do
      before do
        # Create some invoices for order
        order_proforma = Organization::Proformas::Create.call(
          order_version.id,
          {
            invoice_amounts: [
              { original_item_uuid: order.last_version.items.first.original_item_uuid, invoice_amount: 22 },
              { original_item_uuid: order.last_version.items.second.original_item_uuid, invoice_amount: 33 }
            ]
          }
        ).data
        Accounting::Proformas::Post.call(order_proforma.id).data

        # Create some invoices for another_order
        another_order_proforma = Organization::Proformas::Create.call(
          another_order.last_version.id,
          {
            invoice_amounts: [
              { original_item_uuid: another_order.last_version.items.first.original_item_uuid, invoice_amount: 22 }
            ]
          }
        ).data
        Accounting::Proformas::Post.call(another_order_proforma.id).data
      end

      let(:expected_average_completion_percentage) do
        # first order completion percentage = 55 / 1 315 = 0.0418
        # another order completion percentage = 22 / 1000 = 0.022
        # average = (0.0418 + 0.022) / 2 = 0.03
        0.0319
      end

      it 'returns the average completion percentage of the orders created between today and the beggining of the year' do
        expect(result.data).to eq(0.03)
      end

      context 'when some orders have been created before end_date.beggining_of_year' do
        before { order.update!(created_at: end_date.beginning_of_year - 2.days) }

        it 'returns the average completion percentage of the relevant orders only' do
          # Only take the another_order into account
          expect(result.data).to eq(0.02)
        end
      end
    end

    context 'when websocket channel is provided' do
      let(:websocket_channel_id) { 'test_channel' }

      before do
        allow(ActionCable.server).to receive(:broadcast)
      end

      it 'broadcasts the results to the websocket channel' do
        result

        expect(ActionCable.server).to have_received(:broadcast).with(
          websocket_channel_id,
          {
            'type' => 'KpiAverageOrderCompletionGenerated',
            'data' => 0.0
          }
        )
      end
    end
  end
end
