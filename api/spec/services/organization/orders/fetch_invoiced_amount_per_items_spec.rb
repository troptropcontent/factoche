require 'rails_helper'
require 'support/shared_contexts/organization/projects/a_company_with_an_order'
require 'services/shared_examples/service_result_example'

RSpec.describe Organization::Orders::FetchInvoicedAmountPerItems do
  subject(:result) { described_class.call(order_id, issue_date) }

  include_context 'a company with an order'

  let(:order_id) { order.id }
  let(:version) { create(:order_version, order: order) }
  let(:issue_date) { Time.current }

  describe '#call' do
    context 'when there are no transactions' do
      it_behaves_like 'a success'

      it 'returns an empty hash' do
        expect(result.data).to eq({})
      end
    end

    context 'when there are invoice and credit note transactions' do
      before {
        # Create a first invoice
        first_invoice = FactoryBot.create(:invoice,
          company_id: company.id,
          holder_id: order_version.id,
          number: "INV-2024-00001",
          status: :posted,
          issue_date: Time.current - 1.day
        ).tap { |invoice|
          FactoryBot.create(:financial_transaction_line,
            financial_transaction: invoice,
            holder_id: first_item.original_item_uuid,
            excl_tax_amount: 100.0
          )
        }

        # Create a credit note for this invoice
        FactoryBot.create(:credit_note,
          company_id: company.id,
          holder_id: first_invoice.id,
          number: "CN-2024-00001",
          status: :posted,
          issue_date: Time.current - 1.day
        ).tap { |invoice|
          FactoryBot.create(:financial_transaction_line,
            financial_transaction: invoice,
            holder_id: first_item.original_item_uuid,
            excl_tax_amount: 100.0
          )
        }

        # Create a second invoice
        FactoryBot.create(:invoice,
          company_id: company.id,
          holder_id: order_version.id,
          number: "INV-2024-00002",
          status: :posted,
          issue_date: Time.current - 1.day
        ).tap { |invoice|
          FactoryBot.create(:financial_transaction_line,
            financial_transaction: invoice,
            holder_id: first_item.original_item_uuid,
            excl_tax_amount: 100.0
          )
          FactoryBot.create(:financial_transaction_line,
            financial_transaction: invoice,
            holder_id: second_item.original_item_uuid,
            quantity: 2,
            unit_price_amount: 100.0,
            excl_tax_amount: 200.0
          )
        }
      }

      it_behaves_like 'a success'

      it 'calculates correct amounts per holder', :aggregate_failures do
        expect(result.data[first_item.original_item_uuid]).to eq({
          invoices_amount: 200.0,
          credit_notes_amount: 100.0
        })
        expect(result.data[second_item.original_item_uuid]).to eq({
          invoices_amount: 200.0,
          credit_notes_amount: 0.0
        })
      end

      context 'when issue_date is in the past' do
        let(:issue_date) { Time.current - 2.days }

        it_behaves_like 'a success'

        it 'excludes transactions after the issue date' do
          expect(result.data).to eq({})
        end
      end
    end
  end
end
