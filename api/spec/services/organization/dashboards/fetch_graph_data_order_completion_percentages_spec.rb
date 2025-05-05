require 'rails_helper'
require 'support/shared_contexts/organization/projects/a_company_with_some_orders'
require 'services/shared_examples/service_result_example'

RSpec.describe Organization::Dashboards::FetchGraphDataOrderCompletionPercentages do
  subject(:result) { described_class.call(company_id:, end_date:, websocket_channel_id:) }

  include_context 'a company with some orders', number_of_orders: 3

  # Setup the quote that will converted to `first_order` to obtain an order with a total value of 100 * 100 + 100 * 100 + 100 * 100 = 30 000
  let(:first_quote_first_item_unit_price_amount) { 100 }
  let(:first_quote_first_item_quantity) { 100 }
  let(:first_quote_second_item_unit_price_amount) { 100 }
  let(:first_quote_second_item_quantity) { 100 }
  let(:first_quote_third_item_unit_price_amount) { 100 }
  let(:first_quote_third_item_quantity) { 100 }

  # Setup the quote that will converted to `second_order` to obtain an order with a total value of 100 * 100 + 100 * 100 + 100 * 100 = 30 000
  let(:second_quote_first_item_unit_price_amount) { 100 }
  let(:second_quote_first_item_quantity) { 100 }
  let(:second_quote_second_item_unit_price_amount) { 100 }
  let(:second_quote_second_item_quantity) { 100 }
  let(:second_quote_third_item_unit_price_amount) { 100 }
  let(:second_quote_third_item_quantity) { 100 }

  # Setup the quote that will converted to `third_order` to obtain an order with a total value of 100 * 100 + 100 * 100 + 100 * 100 = 30 000
  let(:third_quote_first_item_unit_price_amount) { 100 }
  let(:third_quote_first_item_quantity) { 100 }
  let(:third_quote_second_item_unit_price_amount) { 100 }
  let(:third_quote_second_item_quantity) { 100 }
  let(:third_quote_third_item_unit_price_amount) { 100 }
  let(:third_quote_third_item_quantity) { 100 }

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
        # Set the first_order created_at to January 1, 2024. and create some revenues on it. This order should be present in the result as created within the year.
        first_order.update(created_at: DateTime.new(2024, 1, 1))
        first_proforma = Organization::Proformas::Create.call(
          first_order.last_version.id,
          {
            invoice_amounts: [
              { original_item_uuid: first_order.last_version.items.first.original_item_uuid, invoice_amount: 10000 },
              { original_item_uuid: first_order.last_version.items.second.original_item_uuid, invoice_amount: 10000 }
            ]
          }
        ).data
        Accounting::Proformas::Post.call(first_proforma.id).data

        # Set the second_order created_at to February 1, 2024. and create some revenues on it. This order should be present in the result as created within the year.
        second_order.update(created_at: DateTime.new(2024, 2, 1))
        second_proforma = Organization::Proformas::Create.call(
          second_order.last_version.id,
          {
            invoice_amounts: [
              { original_item_uuid: second_order.last_version.items.first.original_item_uuid, invoice_amount: 321.99 }
            ]
          }
        ).data
        second_invoice = Accounting::Proformas::Post.call(second_proforma.id).data

        Accounting::Invoices::Cancel.call(second_invoice.id).data

        third_proforma = Organization::Proformas::Create.call(
          second_order.last_version.id,
          {
            invoice_amounts: [
              { original_item_uuid: second_order.last_version.items.first.original_item_uuid, invoice_amount: 10000 }
            ]
          }
        ).data
        Accounting::Proformas::Post.call(third_proforma.id).data

        # Set the second_order created_at to December 31, 2023. and create some revenues on it. This order should not be present in the result as npt created within the year.
        third_proforma = Organization::Proformas::Create.call(
          third_order.last_version.id,
          {
            invoice_amounts: [
              { original_item_uuid: third_order.last_version.items.first.original_item_uuid, invoice_amount: 10000 },
              { original_item_uuid: third_order.last_version.items.second.original_item_uuid, invoice_amount: 10000 },
              { original_item_uuid: third_order.last_version.items.third.original_item_uuid, invoice_amount: 10000 }
            ]
          }
        ).data
        Accounting::Proformas::Post.call(third_proforma.id).data
      end

      let(:expected) do
        [
          {
            id: first_order.id,
            name: first_order.name,
            order_total_amount: 30000.0,
            invoiced_total_amount: 20000.0,
            completion_percentage: 0.67
          },
          {
            id: second_order.id,
            name: second_order.name,
            order_total_amount: 30000.0,
            invoiced_total_amount: 10000.0,
            completion_percentage: 0.33
          }
        ]
      end

      it_behaves_like 'a success'

      it 'returns the monthly revenues for the specified year' do
        expect(result.data).to eq(expected)
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
            'type' => 'GraphDataOrderCompletionPercentagesGenerated',
            'data' => []
          }
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end
