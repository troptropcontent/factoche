require 'rails_helper'
require "support/shared_contexts/organization/a_company_with_a_project_with_three_items"

RSpec.describe Accounting::Invoices::Void do
  describe '.call' do
    include_context 'a company with a project with three items'

    let(:invoice) {
      Organization::Invoices::Create.call(project_version.id, {
        invoice_amounts: [
          { original_item_uuid: first_item.original_item_uuid, invoice_amount: 1 },
          { original_item_uuid: second_item.original_item_uuid, invoice_amount: 2 }
        ]
      }).data
    }
    let(:invoice_id) { invoice.id }

    context 'when successful' do
      it 'returns success with voided invoice', :aggregate_failures do
        result = described_class.call(invoice_id)

        expect(result).to be_success
        expect(result.data).to eq(invoice)
        expect(result.data.status).to eq("voided")
      end

      it 'updates invoice status to voided' do
        expect {
          described_class.call(invoice_id)
        }.to change { invoice.reload.status }.from("draft").to("voided")
      end
    end

    context 'when invoice_id is blank' do
      let(:invoice_id) { nil }

      it 'returns failure', :aggregate_failures do
        result = described_class.call(invoice_id)

        expect(result).to be_failure
        expect(result.error).to eq("Invoice ID is required")
      end
    end

    context 'when invoice is not found' do
      let(:invoice_id) { -1 }

      it 'returns failure', :aggregate_failures do
        result = described_class.call(invoice_id)

        expect(result).to be_failure
        expect(result.error).to include("Couldn't find Accounting::Invoice")
      end
    end

    context 'when invoice is not in draft status' do
      before do
        invoice.update!(status: :posted, number: 'INV-2024-0001')
      end

      it 'returns failure', :aggregate_failures do
        result = described_class.call(invoice_id)

        expect(result).to be_failure
        expect(result.error).to eq("Cannot void invoice that is not in draft status")
      end

      it 'does not change invoice status' do
        expect {
          described_class.call(invoice_id)
        }.not_to change { invoice.reload.status }
      end
    end

    context 'when update fails' do
      let(:invoice_double) { instance_double(Accounting::Invoice, draft?: true) }

      before do
        allow(Accounting::Invoice).to receive(:find).and_return(invoice_double)
        allow(invoice_double).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(invoice))
      end

      it 'returns failure', :aggregate_failures do
        result = described_class.call(invoice_id)

        expect(result).to be_failure
        expect(result.error).to include("Validation failed")
      end

      it 'does not change invoice status' do
        expect {
          described_class.call(invoice_id)
        }.not_to change { invoice.reload.status }
      end
    end
  end
end
