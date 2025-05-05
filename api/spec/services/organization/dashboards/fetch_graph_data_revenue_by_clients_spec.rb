require 'rails_helper'
require 'support/shared_contexts/organization/projects/a_company_with_some_orders'
require 'services/shared_examples/service_result_example'

RSpec.describe Organization::Dashboards::FetchGraphDataRevenueByClients do
  subject(:result) { described_class.call(company_id:, end_date:, websocket_channel_id:) }

  include_context 'a company with some orders', number_of_orders: 3

  # Max allowed invoices allowed for this item 100 * 100 => 10 000 €
  let(:first_quote_first_item_unit_price_amount) { 100 }
  let(:first_quote_first_item_quantity) { 100 }

  # Max allowed invoices allowed for this item 200 * 200 => 40 000 €
  let(:second_quote_first_item_unit_price_amount) { 200 }
  let(:second_quote_first_item_quantity) { 200 }

  # Max allowed invoices allowed for this item 300 * 300 => 90 000 €
  let(:third_quote_first_item_unit_price_amount) { 300 }
  let(:third_quote_first_item_quantity) { 300 }

  let(:company_id) { company.id }
  let(:end_date) { DateTime.new(2024, 6, 15) }
  let(:websocket_channel_id) { nil }


  describe '#call' do
    context 'when there are no invoices recorded' do
      it_behaves_like 'a success'

      it 'returns an empty array' do
        expect(result.data).to eq([])
      end
    end

    context 'when there are invoices recorded' do
      before do
        # Create an invoice for the 'first_client' with an issue date of January 1, 2024 this one should be counted
        first_proforma = Organization::Proformas::Create.call(
          first_order.last_version.id,
          {
            invoice_amounts: [
              { original_item_uuid: first_order.last_version.items.first.original_item_uuid, invoice_amount: 123.99 }
            ]
          }
        ).data
        Accounting::Proformas::Post.call(first_proforma.id, DateTime.new(2024, 1, 1)).data

        # Create an invoice for the 'second_client' with an issue date of February 1, 2024 this one should be counted
        second_proforma = Organization::Proformas::Create.call(
          second_order.last_version.id,
          {
            invoice_amounts: [
              { original_item_uuid: second_order.last_version.items.first.original_item_uuid, invoice_amount: 321.99 }
            ]
          }
        ).data
        second_invoice = Accounting::Proformas::Post.call(second_proforma.id, DateTime.new(2024, 2, 1)).data

        # Create an credit note for the 'second_client''s invoice we just created with an issue date of March 1, 2024 this one should be counted
        Accounting::Invoices::Cancel.call(second_invoice.id, DateTime.new(2024, 3, 1)).data

        # Create another invoice for the 'second_client' with an issue date of avril 1, 2024 this one should be counted
        third_proforma = Organization::Proformas::Create.call(
          second_order.last_version.id,
          {
            invoice_amounts: [
              { original_item_uuid: second_order.last_version.items.first.original_item_uuid, invoice_amount: 999.99 }
            ]
          }
        ).data
        Accounting::Proformas::Post.call(third_proforma.id, DateTime.new(2024, 4, 1)).data

        # Create an invoice for the 'third_client' with an issue date of December 31, 2023 this one should not be counted
        third_proforma = Organization::Proformas::Create.call(
          third_order.last_version.id,
          {
            invoice_amounts: [
              { original_item_uuid: third_order.last_version.items.first.original_item_uuid, invoice_amount: 10 }
            ]
          }
        ).data
        Accounting::Proformas::Post.call(third_proforma.id, DateTime.new(2023, 12, 31)).data
      end

      it_behaves_like 'a success'

      it 'returns the monthly revenues for the specified year' do
        expect(result.data).to eq([
          { client_id: first_client.id, revenue: 123.99 },
          { client_id: second_client.id, revenue: 999.99 }
        ])
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
            'type' => 'GraphDataRevenueByClientsGenerated',
            'data' => []
          }
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end
