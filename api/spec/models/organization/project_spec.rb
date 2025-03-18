require 'rails_helper'

RSpec.describe Organization::Project, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }

    describe("unique name within client scope") do
      subject { FactoryBot.build(:quote, name: taken_name, client:) }

      let(:company) { FactoryBot.create(:company) }
      let(:client) { FactoryBot.create(:client, company:) }
      let(:taken_name) { "taken_name" }
      let(:already_existing_project) { FactoryBot.create(:quote, client:, name: taken_name) }


      it { is_expected.to validate_uniqueness_of(:name).scoped_to(:client_id) }
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:client) }
    it { is_expected.to have_many(:versions) }
    it { is_expected.to have_one(:last_version) }
    it { is_expected.to have_many(:invoices) }
    it { is_expected.to have_many(:credit_notes) }
  end

  describe 'nested attributes' do
    it { is_expected.to accept_nested_attributes_for(:versions) }
  end
end
