require 'rails_helper'
module Organization
  RSpec.describe BuildInvoiceFromCompletionSnapshot do
    describe '.call' do
      subject(:new_invoice) { described_class.call(snapshot, issue_date) }

      let(:snapshot) { instance_double(CompletionSnapshot, id: 12) }
      let(:issue_date) { DateTime.now }
      let(:due_date) { Date.tomorrow }
      let(:payload) do
        instance_double(BuildCompletionSnapshotInvoicePayload::Result,
          document_info: instance_double(BuildCompletionSnapshotInvoicePayload::DocumentInfo,
            number: '123',
            issue_date: issue_date,
            due_date: due_date
          ),
          transaction: instance_double(BuildCompletionSnapshotTransactionPayload::Payload,
            total_excl_tax_amount: 100.0,
            tax_amount: 20.0,
            retention_guarantee_amount: 10.0,
            invoice_total_amount: 130.0
          )
        )
      end

      before do
        allow(BuildCompletionSnapshotInvoicePayload).to receive(:call)
          .with(snapshot, issue_date)
          .and_return(payload)
      end

      it 'creates an invoice with correct attributes' do
        aggregate_failures do
          expect(new_invoice.number).to eq('123')
          expect(new_invoice.issue_date.to_i).to eq(issue_date.to_i)
          expect(new_invoice.delivery_date.to_i).to eq(issue_date.to_i)
          expect(new_invoice.due_date.to_date).to eq(due_date.to_date)
          expect(new_invoice.total_excl_tax_amount).to eq(100.0)
          expect(new_invoice.tax_amount).to eq(20.0)
          expect(new_invoice.retention_guarantee_amount).to eq(10.0)
          expect(new_invoice.total_amount).to eq(130.0)
        end
      end

      it 'returns an Organization::Invoice instance' do
        expect(new_invoice).to be_an_instance_of(Organization::Invoice)
      end
    end
  end
end
