require "rails_helper"
require "support/shared_contexts/organization/a_company_with_a_project_with_three_item_groups"
module Organization
  module CompletionSnapshots
    RSpec.describe Cancel do
      include_context 'a company with a project with three item groups'
      describe ".call" do
        let(:snapshot) { FactoryBot.create(:completion_snapshot, :with_invoice, project_version: project_version) }
        let(:invoice) { snapshot.invoice }

        context "when snapshot is published" do
          before do
            invoice.update(status: :published)
          end

          it "returns a successful result with credit note", :aggregate_failures do
            result = described_class.call(snapshot)

            expect(result).to be_success
            expect(result.data).to be_a(CreditNote)
            expect(result.error).to be_nil
          end

          it "cancels the invoice" do
            described_class.call(snapshot)
            expect(invoice.reload.status).to eq("cancelled")
          end

          it "creates a credit note from the invoice", :aggregate_failures do
            expect {
              described_class.call(snapshot)
            }.to change(CreditNote, :count).by(1)

            credit_note = CreditNote.last
            expect(credit_note.original_invoice).to eq(invoice)
          end
        end

        context "when snapshot is not published" do
          before do
            invoice.update(status: "draft")
          end

          it "returns a failure result with error", :aggregate_failures do
            result = described_class.call(snapshot)

            expect(result).to be_failure
            expect(result.data).to be_nil
            expect(result.error).to be_a(Error::UnprocessableEntityError)
            expect(result.error.message).to eq(
              "Cannot cancel a completion snapshot that is not published, current snapshot status is draft"
            )
          end

          it "does not create a credit note" do
            expect {
              described_class.call(snapshot)
            }.not_to change(CreditNote, :count)
          end

          it "does not change the invoice status" do
            expect {
              described_class.call(snapshot)
            }.not_to change { invoice.reload.status }
          end
        end

        context "when an unexpected error occurs" do
          before do
            invoice.update(status: "published")
            allow(CreditNotes::BuildCreditNoteFromInvoice).to receive(:call)
              .and_raise(StandardError, "Unexpected error")
          end

          it "returns a failure result with error", :aggregate_failures do
            result = described_class.call(snapshot)

            expect(result).to be_failure
            expect(result.data).to be_nil
            expect(result.error).to be_a(StandardError)
            expect(result.error.message).to eq("Unexpected error")
          end

          it "does not persist any changes due to transaction rollback", :aggregate_failures do
            expect {
              described_class.call(snapshot)
            }.not_to change(CreditNote, :count)

            expect(invoice.reload.status).not_to eq("cancelled")
          end
        end
      end
    end
  end
end
