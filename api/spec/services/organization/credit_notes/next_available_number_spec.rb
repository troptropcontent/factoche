require 'rails_helper'
require "support/shared_contexts/organization/a_company_with_a_project_with_three_item_groups"

RSpec.describe Organization::CreditNotes::NextAvailableNumber do
  describe '.call' do
    include_context 'a company with a project with three item groups'

    context 'when there are no existing credit notes' do
      it 'returns CN-000001' do
        expect(described_class.call(company)).to eq('CN-000001')
      end
    end

    context 'when there are existing credit notes' do
      before do
        3.times do
          completion_snapshot = FactoryBot.create(:completion_snapshot, :with_invoice, project_version: project_version)
          FactoryBot.create(:credit_note, original_invoice: completion_snapshot.invoice)
        end
      end

      it 'returns the next available number' do
        expect(described_class.call(company)).to eq('CN-000004')
      end
    end
  end
end
