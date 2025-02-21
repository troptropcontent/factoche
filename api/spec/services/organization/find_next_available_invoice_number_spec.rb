require 'rails_helper'
require "support/shared_contexts/organization/a_company_with_a_project_with_three_item_groups"

RSpec.describe Organization::FindNextAvailableInvoiceNumber do
  subject(:service) { described_class.new }

  include_context 'a company with a project with three item groups'
  describe '#call' do
    context 'when company has no invoices' do
      it 'returns invoice number starting with 1' do
        expect(service.call(company)).to eq('INV-000001')
      end
    end

    context 'when company has existing invoices' do
      before do
        3.times do
          completion_snapshot =
            FactoryBot.create(
              :completion_snapshot,
              project_version: project_version,
              completion_snapshot_items_attributes: [],
            )
          FactoryBot.create(:invoice, completion_snapshot: completion_snapshot)
        end
      end

      it 'returns the next sequential invoice number' do
        expect(service.call(company)).to eq('INV-000004')
      end
    end
  end
end
