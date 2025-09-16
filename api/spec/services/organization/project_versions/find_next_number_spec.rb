require 'rails_helper'

RSpec.describe Organization::ProjectVersions::FindNextNumber do
  describe '.call' do
    let(:company) { FactoryBot.create(:company, :with_bank_detail) }
    let(:client) { FactoryBot.create(:client, company: company) }
    let(:quote) { FactoryBot.create(:quote, client: client, company: company, bank_detail: company.bank_details.last) }
    let(:quote_version) { FactoryBot.create(:project_version, project: quote) }
    let(:project) { quote }

    context 'when there are no existing versions' do
      it 'returns the first version number', :aggregate_failures do
        result = described_class.call(project)
        expect(result).to be_success
        expect(result.data).to eq("QUO-#{project.id.to_s.rjust(4, '0')}-0000")
      end
    end

    context 'when there are existing versions' do
      before do
        FactoryBot.create_list(:project_version, 3, project: project)
      end

      it 'returns the next version number', :aggregate_failures do
        result = described_class.call(project)
        expect(result).to be_success
        expect(result.data).to eq("QUO-#{project.id.to_s.rjust(4, '0')}-0003")
      end
    end

    context 'when the project is a order' do
      let(:project) { FactoryBot.create(:order, original_project_version: quote_version, client: client, company: company, bank_detail: company.bank_details.last) }

      it 'returns the first version number with the relevant prefix', :aggregate_failures do
        result = described_class.call(project)
        expect(result).to be_success
        expect(result.data).to eq("ORD-#{project.id.to_s.rjust(4, '0')}-0000")
      end
    end

    context 'when an error occurs' do
      before do
        allow(project).to receive(:versions).and_raise(StandardError, "Test error")
      end

      it 'returns a failure result', :aggregate_failures do
        result = described_class.call(project)
        expect(result).to be_failure
        expect(result.error.message).to eq("Test error")
      end
    end
  end
end
