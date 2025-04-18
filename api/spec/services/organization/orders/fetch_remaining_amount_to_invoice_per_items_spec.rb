require 'rails_helper'
require 'support/shared_contexts/organization/projects/a_company_with_an_order'
require 'services/shared_examples/service_result_example'

RSpec.describe Organization::Orders::FetchRemainingAmountToInvoicePerItems do
  describe '#call' do
    subject(:result) { described_class.call(order_id, issue_date) }

    include_context 'a company with an order'
    let(:order_id) { order.id }
    let(:issue_date) { Time.current }

    let(:first_item_unit_price_amount) { 200 }
    let(:first_item_quantity) { 10 }
    let(:second_item_unit_price_amount) { 300 }
    let(:second_item_quantity) { 5 }
    let(:third_item_unit_price_amount) { 400 }
    let(:third_item_quantity) { 8 }

    let(:order_version_first_item) { order_version.items.first }
    let(:order_version_second_item) { order_version.items.second }
    let(:order_version_third_item) { order_version.items.third }

    context 'when order exists' do
      context 'when there are no invoices or credit notes' do
        before do
          allow(Organization::Orders::FetchInvoicedAmountPerItems)
            .to receive(:call)
            .with(order.id, issue_date)
            .and_return(
              ServiceResult.success({
                order_version_first_item.original_item_uuid => { invoices_amount: 0, credit_notes_amount: 0 },
                order_version_second_item.original_item_uuid => { invoices_amount: 0, credit_notes_amount: 0 },
                order_version_third_item.original_item_uuid => { invoices_amount: 0, credit_notes_amount: 0 }
              }
            ))
        end

        it_behaves_like 'a success'

        it 'returns the full amount for each item' do
          expect(result.data).to eq({
            order_version_first_item.original_item_uuid => 2000, # 200 * 10
            order_version_second_item.original_item_uuid => 1500,   # 300 * 5
            order_version_third_item.original_item_uuid => 3200   # 400 * 8
          })
        end
      end

      context 'when there are invoices and credit notes' do
        before do
          allow(Organization::Orders::FetchInvoicedAmountPerItems)
            .to receive(:call)
            .with(order.id, issue_date)
            .and_return(ServiceResult.success(
                order_version_first_item.original_item_uuid => { invoices_amount: 150, credit_notes_amount: 25 },
                order_version_second_item.original_item_uuid => { invoices_amount: 200, credit_notes_amount: 12 },
                order_version_third_item.original_item_uuid => { invoices_amount: 3200, credit_notes_amount: 1600 }
            ))
        end

        it_behaves_like 'a success'

        it 'calculates the remaining amount correctly' do
          expect(result.data).to eq({
            order_version_first_item.original_item_uuid => 1875, # ( 200 * 10 ) - 150 + 25
            order_version_second_item.original_item_uuid => 1312,   # ( 300 * 5 ) - 200 + 12
            order_version_third_item.original_item_uuid => 1600   # ( 400 * 8 ) - 3200 + 1600
          })
        end
      end

      context 'when FetchInvoicedAmountPerItems fails' do
        before do
          allow(Organization::Orders::FetchInvoicedAmountPerItems)
            .to receive(:call)
            .with(order.id, issue_date)
            .and_return(ServiceResult.failure(StandardError.new('Failed to fetch invoiced amounts')))
        end

        it_behaves_like 'a failure'

        it 'raises the error from FetchInvoicedAmountPerItems' do
          expect(result.error.message).to include('Failed to fetch invoiced amounts')
        end
      end
    end
  end
end
