require 'rails_helper'

RSpec.describe Organization::Quote, type: :model do
  describe 'validations' do
    let(:company) { FactoryBot.create(:company, :with_bank_detail) }
    let(:client) { FactoryBot.create(:client, company: company) }
    let(:quote) { FactoryBot.build(:quote, client: client, company: company, bank_detail: company.bank_details.last) }

    it 'is valid without original_project_version_id' do
      expect(quote).to be_valid
    end

    it 'is invalid with original_project_version_id', :aggregate_failures do
      # Create a project version to reference
      other_quote = FactoryBot.create(:quote, client: client, company: company, bank_detail: company.bank_details.last)
      version = FactoryBot.create(:project_version, project: other_quote)

      quote.original_project_version_id = version.id
      expect(quote).not_to be_valid
      expect(quote.errors[:original_project_version_id]).to include("must be blank")
    end

    it 'inherits Project validations', :aggregate_failures do
      quote.client = nil
      expect(quote).not_to be_valid
      expect(quote.errors[:client]).to include("must exist")
    end
  end

  describe 'type checks' do
    let(:quote) { FactoryBot.build(:quote) }

    it 'has the correct STI type' do
      expect(quote.type).to eq('Organization::Quote')
    end

    it 'is an instance of Quote' do
      expect(quote).to be_instance_of(described_class)
    end

    it 'is a kind of Project' do
      expect(quote).to be_a(Organization::Project)
    end
  end
end
