require 'rails_helper'

RSpec.describe Organization::CompletionSnapshot, type: :model do
  subject(:completion_snapshot) {
    FactoryBot.create(:completion_snapshot, project_version: project_version)
  }

  let(:invoice) { FactoryBot.create(:invoice, completion_snapshot: completion_snapshot) }
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
      context "when there is no invoice" do
        it "raises an error" do
          expect { completion_snapshot.status }.to raise_error(ActiveSupport::DelegationError, 'status delegated to invoice, but invoice is nil')
        end
      end

      context "when there is an invoice" do
        before { invoice }

        it "delegates to the invoice status" do
          expect(completion_snapshot.status).to eq(invoice.status)
        end

        it "changes when invoice status changes" do
          invoice.update(status: :published)
          expect(completion_snapshot.status).to eq("published")
        end
      end
    end
  end
end
