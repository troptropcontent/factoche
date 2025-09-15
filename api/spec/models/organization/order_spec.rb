require 'rails_helper'

RSpec.describe Organization::Order, type: :model do
  describe 'validations' do
    let(:company) { FactoryBot.create(:company, :with_bank_detail) }
    let(:client) { FactoryBot.create(:client, company: company) }
    let(:original_quote) { FactoryBot.create(:quote, client: client, company: company) }
    let(:original_project_version) { FactoryBot.create(:project_version, project: original_quote, bank_detail: company.bank_details.last) }
    let(:order) { FactoryBot.build(:order, client: client, company: company, original_project_version: original_project_version) }

    it 'is valid with original_project_version_id' do
      expect(order).to be_valid
    end

    it 'is invalid without original_project_version_id', :aggregate_failures do
      order.original_project_version_id = nil
      expect(order).not_to be_valid
      expect(order.errors[:original_project_version_id]).to include("can't be blank")
    end

    it 'inherits Project validations', :aggregate_failures do
      order.client = nil
      expect(order).not_to be_valid
      expect(order.errors[:client]).to include("must exist")
    end
  end

  describe 'associations' do
    let(:company) { FactoryBot.create(:company, :with_bank_detail) }
    let(:client) { FactoryBot.create(:client, company: company) }
    let(:original_quote) { FactoryBot.create(:quote, client: client, company: company) }
    let(:original_project_version) { FactoryBot.create(:project_version, project: original_quote, bank_detail: company.bank_details.last) }
    let(:order) { FactoryBot.create(:order, client: client, original_project_version: original_project_version, company: company) }

    it 'belongs to original_project_version' do
      expect(order.original_project_version).to eq(original_project_version)
    end

    it 'can find the original quote through the version' do
      expect(order.original_project_version.project).to eq(original_quote)
    end
  end

  describe 'type checks' do
    let(:order) { FactoryBot.build(:order) }

    it 'has the correct STI type' do
      expect(order.type).to eq('Organization::Order')
    end

    it 'is an instance of Order' do
      expect(order).to be_instance_of(described_class)
    end

    it 'is a kind of Project' do
      expect(order).to be_a(Organization::Project)
    end
  end
end
