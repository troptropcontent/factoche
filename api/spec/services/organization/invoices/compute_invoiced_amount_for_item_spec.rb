require "rails_helper"
require "support/shared_contexts/organization/a_company_with_a_project_with_three_item_groups"
# rubocop:disable RSpec/MultipleMemoizedHelpers

module Organization
  module Invoices
    RSpec.describe ComputeInvoicedAmountForItem do
      include_context 'a company with a project with three item groups'
      let(:project_version_first_item_group_item_quantity) { 1 }
      let(:project_version_first_item_group_item_unit_price_cents) { 1000 }
      let(:project_version_second_item_group_item_quantity) { 2 }
      let(:project_version_second_item_group_item_unit_price_cents) { 2000 }
      let(:project_version_third_item_group_item_quantity) { 3 }
      let(:project_version_third_item_group_item_unit_price_cents) { 3000 }
      let(:original_item_uuid) { project_version_second_item_group_item.original_item_uuid }
      let(:issue_date) { Time.current }

      describe ".call" do
        context "when successful" do
          before do
            # Create a first completion snapshot
            first_completion_snapshot = FactoryBot.create(
              :completion_snapshot, :with_invoice,
              project_version: project_version,
              completion_snapshot_items_attributes: [ {
                item_id: project_version_first_item_group_item.id,
                completion_percentage: "0.10"
              },
              {
                item_id: project_version_second_item_group_item.id,
                completion_percentage: "0.20"
              },
              {
                item_id: project_version_third_item_group_item.id,
                completion_percentage: "0.30"
              } ]
            )
            # Publish the invoice
            first_completion_snapshot.invoice.update(status: :published)

            # Generate a credit note for this invoice and publish it
            first_completion_snapshot_credit_note = CreditNotes::BuildCreditNoteFromInvoice.call(first_completion_snapshot.invoice)

            first_completion_snapshot_credit_note.status = :published

            first_completion_snapshot_credit_note.save!

            # Generate a second completion snapshot

            second_completion_snapshot = FactoryBot.create(
              :completion_snapshot, :with_invoice,
              project_version: project_version,
              completion_snapshot_items_attributes: [
              {
                item_id: project_version_second_item_group_item.id,
                completion_percentage: "0.50"
              } ]
            )

            # Publish the second invoice
            second_completion_snapshot.invoice.update!(status: :published)
          end

          it "computes the total invoiced amount for a specific item minus credit notes ammount for a specific item", :aggregate_failures do
            result = described_class.call(project, original_item_uuid, issue_date)

            expect(result).to be_success
            # invoice 1 = 20 % (completion percentage) * 20 € (unit price) * 2 quantity)  = 2 €
            # credit note 1 = 1 €
            # invoice 2 = 50 % (completion percentage) * 20 € (unit price) * 2 quantity)  = 20 €
            expect(result.data).to eq(BigDecimal("20.00"))
            expect(result.error).to be_nil
          end

            context "when there are draft invoices/credit notes" do
              before { project.invoices.last.update!(status: :draft) }

              it "excludes draft documents from calculation", :aggregate_failures do
                result = described_class.call(project, original_item_uuid, issue_date)

                expect(result).to be_success
                expect(result.data).to eq(BigDecimal("0.00"))
              end
            end
        end

        context "when there are no invoices or credit notes" do
          it "returns zero", :aggregate_failures do
            result = described_class.call(project, original_item_uuid, issue_date)

            expect(result).to be_success
            expect(result.data).to eq(BigDecimal("0"))
            expect(result.error).to be_nil
          end
        end

        context "when an error occurs" do
          before do
            allow(project).to receive(:invoices).and_raise(StandardError.new("Database error"))
          end

          it "returns a failure result", :aggregate_failures do
            result = described_class.call(project, original_item_uuid, issue_date)

            expect(result).to be_failure
            expect(result.error).to be_a(StandardError)
            expect(result.error.message).to eq("Database error")
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
