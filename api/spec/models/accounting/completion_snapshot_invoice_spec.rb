require 'rails_helper'

module Accounting
  RSpec.describe CompletionSnapshotInvoice do
    subject(:invoice) { described_class.new(holder_id: 2, company_id: 2, context: context) }

    let(:context) do
      {
        project_version_number: 1,
        project_version_date: Time.current.iso8601,
        project_total_amount: BigDecimal('1000.00'),
        project_total_previously_billed_amount: BigDecimal('500.00'),
        project_version_retention_guarantee_rate: BigDecimal('0.05'),
        project_version_items: [
          {
            original_item_uuid: SecureRandom.uuid,
            name: 'Item 1',
            description: 'Description 1',
            quantity: 2,
            unit: 'pieces',
            unit_price_amount: BigDecimal('100.00'),
            previously_billed_amount: BigDecimal('50.00'),
            tax_rate: BigDecimal("0.2"),
            group_id: nil
          }
        ],
        project_version_item_groups: [
          {
            id: 1,
            name: 'Group 1',
            description: 'Description 1'
          }
        ]
      }
    end

    describe 'validations' do
      context 'when all attributes are valid' do
        it { is_expected.to be_valid }
      end

      context 'when the context is not valid' do
        before { context[:project_version_number] = "b" }

        it { is_expected.not_to be_valid }

        it "sets an error message that points to the relevant field" do
          invoice.valid?
          expect(invoice.errors[:context]).to include("project_version_number must be an integer")
        end
      end
    end
  end
end
