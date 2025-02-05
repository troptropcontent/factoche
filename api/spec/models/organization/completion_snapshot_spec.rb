require 'rails_helper'

RSpec.describe Organization::CompletionSnapshot, type: :model do
  subject(:completion_snapshot) { FactoryBot.create(:completion_snapshot, project_version: project_version) }

  let(:company) { FactoryBot.create(:company) }
  let(:client) { FactoryBot.create(:client, company: company) }
  let(:project) { FactoryBot.create(:project, client: client) }
  let(:project_version) { FactoryBot.create(:project_version, project: project) }

  describe 'associations' do
    it { is_expected.to belong_to(:project_version).class_name('Organization::ProjectVersion') }
    it { is_expected.to have_many(:completion_snapshot_items).class_name('Organization::CompletionSnapshotItem') }
  end

  describe "instance methods" do
    describe "#status" do
      context "when neither an invoice nor a credit note is attached" do
        it "returns draft" do
          expect(completion_snapshot.status).to eq("draft")
        end
      end

      context "when an invoice_id is there but no credit_note" do
        before { completion_snapshot.update({ invoice: FactoryBot.create(:invoice) }) }

        it "returns invoiced" do
          expect(completion_snapshot.status).to eq("invoiced")
        end
      end

      context "when a credit_note is there" do
        before { completion_snapshot.update({ invoice: FactoryBot.create(:invoice), credit_note:  FactoryBot.create(:credit_note) }) }

        it "returns cancelled" do
          expect(completion_snapshot.status).to eq("cancelled")
        end
      end
    end
  end
end
