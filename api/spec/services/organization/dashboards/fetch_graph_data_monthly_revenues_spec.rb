require 'rails_helper'
require 'support/shared_contexts/organization/projects/a_company_with_an_order'

RSpec.describe Organization::Dashboards::FetchGraphDataMonthlyRevenues do
  subject(:result) { described_class.call(company_id:, year:, websocket_channel_id:) }

  include_context 'a company with an order'

  let(:first_item_unit_price_amount) { 100 }
  let(:first_item_quantity) { 1 }
  let(:second_item_unit_price_amount) { 200 }
  let(:second_item_quantity) { 2 }
  let(:third_item_unit_price_amount) { 300 }
  let(:third_item_quantity) { 3 }

  let(:another_quote_params) do
    # Setup items to have a project version total equal to 1 000 * 1 = 1 000 €
    {
      name: "New windows in Biarritz",
      description: "A brand new set of windows for the police station",
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
    Organization::Quotes::Create.call(company.id, client.id, another_quote_params).data
  end

  let(:another_draft_order) do
    Organization::Quotes::ConvertToDraftOrder.call(another_quote.id).data
  end

  let!(:another_order) do
    Organization::DraftOrders::ConvertToOrder.call(another_draft_order.id).data
  end

  let(:year) { 2024 }
  let(:company_id) { company.id }
  let(:websocket_channel_id) { nil }

  describe '#call' do
    context 'when there are no invoices recorded' do
      it 'returns nil for each month' do
        expect(result.data).to eq({
          "january" => nil,
          "february" => nil,
          "march" => nil,
          "april" => nil,
          "may" => nil,
          "june" => nil,
          "july" => nil,
          "august" => nil,
          "september" => nil,
          "october" => nil,
          "november" => nil,
          "december" => nil
        })
      end
    end

    context 'when there are invoices recorded' do
      before do
        # Create an invoice with an issue date of January 1 2024, this one should be counted
        first_proforma = Organization::Proformas::Create.call(
          another_order.last_version.id,
          {
            invoice_amounts: [
              { original_item_uuid: another_order.last_version.items.first.original_item_uuid, invoice_amount: 10 }
            ]
          }
        ).data
        Accounting::Proformas::Post.call(first_proforma.id, DateTime.new(2024, 1, 1)).data

        # Create another invoice with an issue date of February 1 2024, this one should be counted
        second_proforma = Organization::Proformas::Create.call(
          another_order.last_version.id,
          {
            invoice_amounts: [
              { original_item_uuid: another_order.last_version.items.first.original_item_uuid, invoice_amount: 10 }
            ]
          }
        ).data
        Accounting::Proformas::Post.call(second_proforma.id, DateTime.new(2024, 2, 1)).data

        # Create another invoice with an issue date of December 31 2023, this one should NOT be counted
        third_proforma = Organization::Proformas::Create.call(
          another_order.last_version.id,
          {
            invoice_amounts: [
              { original_item_uuid: another_order.last_version.items.first.original_item_uuid, invoice_amount: 10 }
            ]
          }
        ).data
        Accounting::Proformas::Post.call(third_proforma.id, DateTime.new(2023, 12, 31)).data
      end

      it 'returns the monthly revenues for the specified year' do
        expect(result.data).to eq({
          "january" => 10,
          "february" => 10,
          "march" => nil,
          "april" => nil,
          "may" => nil,
          "june" => nil,
          "july" => nil,
          "august" => nil,
          "september" => nil,
          "october" => nil,
          "november" => nil,
          "december" => nil
        })
      end
    end

    context 'when websocket channel is provided' do
      let(:websocket_channel_id) { 'test_channel' }

      before do
        allow(ActionCable.server).to receive(:broadcast)
      end

      # rubocop:disable RSpec/ExampleLength
      it 'broadcasts the results to the websocket channel' do
        result

        expect(ActionCable.server).to have_received(:broadcast).with(
          websocket_channel_id,
          {
            'type' => 'GraphDataMonthlyRevenuesGenerated',
            'data' => {
              "january" => nil,
              "february" => nil,
              "march" => nil,
              "april" => nil,
              "may" => nil,
              "june" => nil,
              "july" => nil,
              "august" => nil,
              "september" => nil,
              "october" => nil,
              "november" => nil,
              "december" => nil
            }
          }
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end
