require 'rails_helper'

RSpec.describe Organization::Project, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    describe("unique name within client scope") do
      let(:company) { FactoryBot.create(:company) }
      let(:client) { FactoryBot.create(:client, company:) }
      let(:taken_name) { "taken_name" }
      let(:already_existing_project) { FactoryBot.create(:project, client:, name: taken_name) }
      subject { FactoryBot.build(:project, name: taken_name, client:) }
      it { should validate_uniqueness_of(:name).scoped_to(:client_id) }
    end
  end

  describe 'associations' do
    it { should belong_to(:client) }
    it { should have_many(:versions) }
    it { should have_one(:last_version) }
  end

  describe 'nested attributes' do
    it { should accept_nested_attributes_for(:versions) }
  end
end
