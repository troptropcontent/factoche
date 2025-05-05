require 'rails_helper'
require 'support/shared_contexts/organization/projects/a_company_with_an_order'
require 'services/shared_examples/service_result_example'

RSpec.describe Accounting::Proformas::Void do
  shared_examples 'it does not change the proforma status' do
    it 'does not change proforma status' do
      expect { result }.not_to change { proforma.reload.status }
    end
  end

  describe '.call' do
    subject(:result) { described_class.call(proforma_id) }

    include_context 'a company with an order'

    let(:proforma) {
      Organization::Proformas::Create.call(order_version.id, {
        invoice_amounts: [
          { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: 1 },
          { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: 2 }
        ]
      }).data
    }

    let(:proforma_id) { proforma.id }

    context 'when successful' do
      it_behaves_like 'a success'

      it 'returns success with voided proforma', :aggregate_failures do
        expect(result.data).to eq(proforma)
        expect(result.data.status).to eq("voided")
      end

      it 'updates invoice status to voided' do
        expect {
          result
        }.to change { proforma.reload.status }.from("draft").to("voided")
      end
    end

    context 'when proforma_id is blank' do
      let(:proforma_id) { nil }

      it_behaves_like 'a failure', "Proforma ID is required"

      it_behaves_like 'it does not change the proforma status'
    end

    context 'when invoice is not found' do
      let(:proforma_id) { -1 }

      it_behaves_like 'a failure', "Couldn't find Accounting::Proforma with 'id'=-1"

      it_behaves_like 'it does not change the proforma status'
    end

    context 'when invoice is not in draft status' do
      before do
        proforma.update!(status: :posted)
      end

      it_behaves_like 'a failure', "Cannot void a proforma that is not in draft status"

      it_behaves_like 'it does not change the proforma status'
    end

    context 'when update fails' do
      let(:proforma_double) { instance_double(Accounting::Proforma, draft?: true) }

      before do
        allow(Accounting::Proforma).to receive(:find).and_return(proforma_double)
        allow(proforma_double).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(proforma))
      end

      it_behaves_like 'a failure', 'Validation failed'

      it_behaves_like 'it does not change the proforma status'
    end
  end
end
