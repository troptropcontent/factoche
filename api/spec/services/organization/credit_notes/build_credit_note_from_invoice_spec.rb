require 'rails_helper'
require "support/shared_contexts/organization/a_company_with_a_project_with_three_item_groups"

module Organization
  module CreditNotes
    RSpec.describe BuildCreditNoteFromInvoice do
      include_context 'a company with a project with three item groups'

      describe '.call' do
        let(:completion_snapshot) { FactoryBot.create(:completion_snapshot, :with_invoice, project_version: project_version) }

        # rubocop:disable RSpec/ExampleLength
        it 'creates a new credit note with correct attributes', :aggregate_failures do
          issue_date = Time.current
          invoice = completion_snapshot.invoice
          result = described_class.call(invoice, issue_date)

          expect(result).to be_a(CreditNote)
          expect(result).to be_a(CreditNote)
          expect(result.original_invoice_id).to eq(invoice.id)
          expect(result.issue_date).to be_within(1.second).of(issue_date)
          expect(result.number).to eq("CN-2025-000001")
          expect(result.tax_amount).to eq(invoice.tax_amount)
          expect(result.retention_guarantee_amount).to eq(invoice.retention_guarantee_amount)
          expect(result.total_excl_tax_amount).to eq(invoice.total_excl_tax_amount)
          expect(result.total_amount).to eq(invoice.total_amount)
          expect(result.status).to eq('draft')

          expect(result).not_to be_persisted
        end
        # rubocop:enable RSpec/ExampleLength
      end
    end
  end
end
