require 'rails_helper'
require 'support/shared_contexts/organization/projects/a_company_with_some_orders'
require 'services/shared_examples/service_result_example'

RSpec.describe Organization::Dashboards::FetchGraphDataInvoicesPaymentStatus do
    subject(:result) { described_class.call(company_id:, end_date: end_date, websocket_channel_id:) }

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
    let(:websocket_channel_id) { nil }
    let(:end_date) { Time.new(2024, 06, 15, 12, 0, 0) }


    describe '#call' do
      context 'when there are no invoices recorded' do
        it_behaves_like 'a success'

        it 'returns 0 for each payment status' do
          expect(result.data).to eq({ overdue: 0.0, paid: 0.0, pending: 0.0 })
        end
      end

      context 'when there are invoices recorded' do
        before do
            # Create an invoice on first_order with an issue_date on January 1 and a due_date on january 31 2024, 2024. This invoice should be counted as overdue
            first_proforma = Organization::Proformas::Create.call(
              first_order.last_version.id,
              {
                invoice_amounts: [
                  { original_item_uuid: first_order.last_version.items.first.original_item_uuid, invoice_amount: 10000 },
                  { original_item_uuid: first_order.last_version.items.second.original_item_uuid, invoice_amount: 10000 }
                ]
              },
            ).data
            Accounting::Proformas::Post.call(first_proforma.id, DateTime.new(2024, 1, 1)).data

            # Create an invoice on second_order with an issue_date on February 1 and a due_date on March 2 2024, 2024. This invoice should be counted as paid as we alo recorded a payment for it.
            second_proforma = Organization::Proformas::Create.call(
              second_order.last_version.id,
              {
                invoice_amounts: [
                  { original_item_uuid: second_order.last_version.items.first.original_item_uuid, invoice_amount: 321.99 }
                ]
              }
            ).data
            second_invoice = Accounting::Proformas::Post.call(second_proforma.id, DateTime.new(2024, 2, 1)).data
            Accounting::Payments::Create.call(second_invoice.id)

            # Create an other invoice on second_order with an issue_date on March 1 and a due_date on April 1 2024, 2024. This invoice should be counted as overdue.

            third_proforma = Organization::Proformas::Create.call(
              second_order.last_version.id,
              {
                invoice_amounts: [
                  { original_item_uuid: second_order.last_version.items.first.original_item_uuid, invoice_amount: 500 }
                ]
              }
            ).data

            Accounting::Proformas::Post.call(third_proforma.id, DateTime.new(2024, 2, 1)).data

            # Create an other invoice on third_order with an issue_date on June 1 and a due_date on July 1 2024. This invoice should be counted as pending.
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
            Accounting::Proformas::Post.call(third_proforma.id, DateTime.new(2024, 6, 1)).data
        end

        let(:expected) do
          {
            overdue: 0.5, # 2 invoices (1rst invoice and 3rd invoice) / 4 invoices in total
            paid: 0.25, # 1 invoice (2nd invoice) / 4 invoices in total
            pending: 0.25 # 1 invoice (4rth invoice) / 4 invoices in total
          }
        end

        it_behaves_like 'a success'

        it 'returns the monthly revenues for the specified year' do
          ActiveRecord::Base.connection.transaction do
            ActiveRecord::Base.connection.execute("SET LOCAL app.now = '#{Time.new(2024, 06, 15, 12, 0, 0).iso8601}'")
            expect(result.data).to eq(expected)
            raise ActiveRecord::Rollback
          end
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
              'type' => 'InvoiceStatusGraphDataGenerated',
              'data' => { overdue: 0.0, paid: 0.0, pending: 0.0 }
            }
          )
        end
        # rubocop:enable RSpec/ExampleLength
      end
    end
end
