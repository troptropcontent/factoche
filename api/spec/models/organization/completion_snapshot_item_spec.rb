require 'rails_helper'
# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Organization::CompletionSnapshotItem, type: :model do
  subject { FactoryBot.create(:completion_snapshot_item, completion_snapshot: project_version_completion_snapshot, item: project_version_item_group.grouped_items.first) }

  let(:company) { FactoryBot.create(:company) }
  let(:client) { FactoryBot.create(:client, company: company) }
  let(:project) { FactoryBot.create(:project, client: client) }
  let(:project_version) { FactoryBot.create(:project_version, project: project) }
  let(:project_version_item_group) { FactoryBot.create(:item_group, project_version: project_version, name: "Item Group", grouped_items_attributes: [ {
    original_item_uuid: SecureRandom.uuid,
    name: "Item",
    unit: "U",
    position: 1,
    unit_price_cents: "1000",
    project_version: project_version,
    quantity: 2
  } ]) }
  let(:project_version_completion_snapshot) { FactoryBot.create(:completion_snapshot, project_version: project_version) }

  describe 'associations' do
    it { is_expected.to belong_to(:completion_snapshot).class_name('Organization::CompletionSnapshot') }
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:completion_percentage).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:completion_percentage).is_less_than_or_equal_to(1) }
  end
end
