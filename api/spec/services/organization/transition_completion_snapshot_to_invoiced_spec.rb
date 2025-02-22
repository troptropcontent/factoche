require 'rails_helper'
require "support/shared_contexts/organization/a_company_with_a_project_with_three_item_groups"
# rubocop:disable RSpec/ExampleLength
# rubocop:disable RSpec/MultipleMemoizedHelpers
module Organization
  RSpec.describe TransitionCompletionSnapshotToInvoiced do
    include_context 'a company with a project with three item groups'
    let(:project_version_first_item_group_item_quantity) { 1 }
    let(:project_version_first_item_group_item_unit_price_cents) { 1000 }
    let(:project_version_second_item_group_item_quantity) { 2 }
    let(:project_version_second_item_group_item_unit_price_cents) { 2000 }
    let(:project_version_third_item_group_item_quantity) { 3 }
    let(:project_version_third_item_group_item_unit_price_cents) { 3000 }
    let(:snapshot) do
      FactoryBot.create(
        :completion_snapshot,
        project_version: project_version,
        completion_snapshot_items_attributes: [
          {
            item_id: project_version_first_item_group_item.id,
            completion_percentage: BigDecimal("0.05")
          },
          {
            item_id: project_version_second_item_group_item.id,
            completion_percentage: BigDecimal("0.10")
          },
          {
            item_id: project_version_third_item_group_item.id,
            completion_percentage: BigDecimal("0.15")
          }
        ]
      )
    end

    before { Organization::BuildInvoiceFromCompletionSnapshot.call(snapshot, Time.current).save! && snapshot.reload }

    describe '.call' do
      context 'when all dependencies are present and valid' do
        it 'update the invoice, trigger the pdf generation and updates the snapshot status', :aggregate_failures do
          issue_date = Time.now
          expect(GenerateAndAttachPdfToInvoiceJob.jobs.size).to eq(0)
          updated_snapshot, published_invoice = described_class.call(snapshot, issue_date)
          expect(GenerateAndAttachPdfToInvoiceJob.jobs.size).to eq(1)
          expect(published_invoice.issue_date).to be_within(1.second).of(issue_date)
          expect(published_invoice.delivery_date).to be_within(1.second).of(issue_date)
          expect(published_invoice.due_date).to be_within(1.second).of(issue_date.advance(days: 30))

          expect(published_invoice).to have_attributes(
            number: 'INV-000001',
            total_excl_tax_amount: 18, # (1 * 10.00 * 0.05) + (2 * 20.00 * 0.10) + (3 * 30.00 * 0.15) = 0.50 + 4.00 + 13.50 = 18.00
            tax_amount: 3.6, # 18.00 * 0.20 = 3.60
            retention_guarantee_amount: 1.08 # (18.00 + 3.60) * 0.05 = 1.08
          )

          expect(updated_snapshot.status).to eq("published")
        end
      end

      context 'when snapshot is not in draft status' do
        before { allow(snapshot).to receive(:status).and_return("published") }

        it 'raises an UnprocessableEntityError' do
          expect {
            described_class.call(snapshot, Time.now)
          }.to raise_error(Error::UnprocessableEntityError, 'Only draft completion snapshots can be transitioned to invoiced')
        end
      end

      context 'when one of the dependencies are missing' do
        context 'when project_version is nil' do
          before do
            snapshot.project_version = nil
          end

          it 'raises an UnprocessableEntityError' do
            expect {
              described_class.call(snapshot, Time.now)
            }.to raise_error(Error::UnprocessableEntityError, 'Project version is not defined')
          end
        end
      end

      context 'with custom company settings' do
        let(:custom_payment_terms) { 45 }
        let(:custom_vat_rate) { "0.25" }

        before do
          company_config.update({ settings: {
            'payment_term' => { 'days' => custom_payment_terms },
            'vat_rate' => custom_vat_rate
          } })
        end

        it 'uses company-specific settings for calculations' do
          issue_date = Time.now
          _, created_invoice = described_class.call(snapshot, issue_date)

          expect(created_invoice).to have_attributes(
            due_date: be_within(1.second).of(issue_date.advance(days: custom_payment_terms)),
            tax_amount: 18 * BigDecimal("0.25")
          )
        end
      end
    end
  end
end
