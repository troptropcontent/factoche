require 'rails_helper'
require "support/shared_contexts/organization/a_company_with_a_project_with_three_item_groups"

RSpec.describe Organization::FindNextAvailableInvoiceNumber do
  subject(:service) { described_class }

  include_context 'a company with a project with three item groups'
  describe '#call' do
    let(:issue_date) { Time.new(2024, 6, 6) }

    context 'when company has no invoices' do
      it 'returns invoice number starting with 1' do
        expect(service.call(company, issue_date)).to eq('INV-2024-000001')
      end
    end

    context 'when company has existing invoices' do
      before do
        3.times do
          FactoryBot.create(
              :completion_snapshot,
              :with_invoice,
              invoice_issue_date: issue_date,
              project_version: project_version,
              completion_snapshot_items_attributes: [],
            )
        end
      end

      it 'returns the next sequential invoice number' do
        expect(service.call(company, issue_date)).to eq('INV-2024-000004')
      end
    end
  end
end
