require 'rails_helper'
require 'services/shared_examples/service_result_example'
require 'support/shared_contexts/organization/projects/a_company_with_an_order'

RSpec.describe Accounting::FinancialTransactions::FindInvoicedAmountForHolderIds do
  describe '#call' do
  subject(:result) { described_class.call(holder_ids, issue_date) }

    include_context 'a company with an order'

    let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }
    let(:first_item_unit_price_amount) { 100 }
    let(:first_item_quantity) { 3 }

    let(:holder_ids) { [ order_version.items.first.original_item_uuid, order_version.items.last.original_item_uuid ] }
    let(:issue_date) { Time.current }

    before {
      # Create an initial proforma
      proforma = Organization::Proformas::Create.call(order_version.id, { issue_date: 2.days.ago.to_date, invoice_amounts: [ {
        original_item_uuid: order_version.items.first.original_item_uuid,
        invoice_amount: 50
      } ] }).data

      # Post the proforma to generate an invoice
      invoice = Accounting::Proformas::Post.call(proforma.id, 1.days.ago).data

      # Cancel the invoice to generate a credit_note
      Accounting::Invoices::Cancel.call(invoice.id, 1.days.ago).data

      # Create another proforma
      proforma = Organization::Proformas::Create.call(order_version.id, { issue_date: 2.days.ago.to_date, invoice_amounts: [ {
        original_item_uuid: order_version.items.first.original_item_uuid,
        invoice_amount: 60
      } ] }).data

      # Post the other proforma to generate an invoice
      Accounting::Proformas::Post.call(proforma.id, 1.days.ago).data
    }


    it 'returns a hash with invoice and credit note amounts per holder', :aggregate_failures do
      expect(result.data[holder_ids.first]).to eq({
        invoices_amount: 110,
        credit_notes_amount: 50
      })
      expect(result.data[holder_ids.last]).to eq({
        invoices_amount: 0,
        credit_notes_amount: 0
      })
    end

    context "with transactions after the issue date" do
      let(:issue_date) { 4.days.ago }

      it 'excludes transactions after the issue date' do
        expect(result.data[holder_ids.first]).to eq({
          invoices_amount: 0,
          credit_notes_amount: 0
        })
      end
    end
  end
end
