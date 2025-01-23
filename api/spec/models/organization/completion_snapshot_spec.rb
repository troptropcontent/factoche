require 'rails_helper'

RSpec.describe Organization::CompletionSnapshot, type: :model do
  subject { FactoryBot.create(:completion_snapshot, project_version: project_version) }
  let(:company) { FactoryBot.create(:company) }
  let(:client) { FactoryBot.create(:client, company: company) }
  let(:project) { FactoryBot.create(:project, client: client) }
  let(:project_version) { FactoryBot.create(:project_version, project: project) }
  describe 'associations' do
    it { should belong_to(:project_version).class_name('Organization::ProjectVersion') }
    it { should have_many(:completion_snapshot_items).class_name('Organization::CompletionSnapshotItem') }
  end
end
