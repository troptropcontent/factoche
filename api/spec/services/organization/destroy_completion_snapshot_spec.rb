require 'rails_helper'


require "support/shared_contexts/organization/a_company_with_a_project_with_three_item_groups"

RSpec.describe Organization::DestroyCompletionSnapshot do
  include_context 'a company with a project with three item groups'
  describe "destroying completion snapshot" do
    context "when the completion snapshot is draft" do
      let!(:completion_snapshot) { FactoryBot.create(:completion_snapshot, :with_invoice,  project_version: project_version) }

      it "removes the record from the database", :aggregate_failures do
        expect {
          described_class.call(completion_snapshot)
        }.to change(Organization::CompletionSnapshot, :count).by(-1)

        expect {
          completion_snapshot.reload
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the completion snapshot is not draft" do
      let!(:completion_snapshot) { FactoryBot.create(:completion_snapshot, :with_invoice, project_version: project_version) }

      before { completion_snapshot.invoice.update(status: :published) }

      it "raises an error and keeps the record in the database", :aggregate_failures do
        expect {
          expect {
            described_class.call(completion_snapshot)
          }.to raise_error(
            Error::UnprocessableEntityError,
            "Cannot delete completion snapshot with status 'published'. Only snapshots in 'draft' status can be deleted"
          )
        }.not_to change(Organization::CompletionSnapshot, :count)

        expect(completion_snapshot.reload).to be_present
      end
    end
  end
end
