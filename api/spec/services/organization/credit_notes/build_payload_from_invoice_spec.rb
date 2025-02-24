require "rails_helper"
require "support/shared_contexts/organization/a_company_with_a_project_with_three_item_groups"
# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Organization::CreditNotes::BuildPayloadFromInvoice do
  subject(:result) { described_class.call(original_invoice, issue_date) }

  include_context 'a company with a project with three item groups'

  let(:issue_date) { Time.current }

  let(:completion_snapshot) do
    FactoryBot.create(:completion_snapshot, :with_invoice, project_version: project_version, completion_snapshot_items_attributes: [
      { item_id: project_version_first_item_group_item.id, completion_percentage: "0.10" },
      { item_id: project_version_second_item_group_item.id, completion_percentage: "0.20" },
      { item_id: project_version_third_item_group_item.id, completion_percentage: "0.30" }
    ])
  end
  let(:original_invoice) { completion_snapshot.invoice }

  describe '#call' do
    context 'when all dependencies are present' do
      it 'returns a valid Result object' do
        expect(result).to be_a(described_class::Result)
      end

      it 'builds document info correctly' do
        expect(result.document_info).to have_attributes(
          issue_date: issue_date,
          original_invoice_date: original_invoice.issue_date,
          original_invoice_number: "INV-2025-000001"
        )
      end

      it 'builds seller info correctly' do
        expect(result.seller).to have_attributes(
          name: company.name,
          phone: company.phone,
          siret: company.registration_number,
          rcs_city: company.rcs_city,
          rcs_number: company.rcs_number,
          vat_number: company.vat_number,
          legal_form: company.legal_form,
          capital_amount: BigDecimal(company.capital_amount_cents) / BigDecimal("100")
        )
      end

      it 'builds billing address correctly', :aggregate_failures do
        expect(result.billing_address).to have_attributes(
          name: client.name
        )
        expect(result.billing_address.address).to have_attributes(
          city: client.address_city,
          street: client.address_street,
          zip: client.address_zipcode
        )
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
