require 'rails_helper'

RSpec.describe Organization::Companies::Update do
  describe '.call', :aggregate_failures do
    subject(:result) { described_class.call(company_id, params) }

    let(:company_id) { company.id }
    let(:company) { FactoryBot.create(:company, :with_config) }
    let(:params) do
      {
        name: 'Updated Company Name',
        configs: {
          default_vat_rate: "0.3"
        }
      }
    end

    context 'with valid parameters' do
      it { is_expected.to be_success }

      it 'updates the company successfully' do
        expect { result }.to change { company.reload.name }.to('Updated Company Name')
      end

      it 'updates company configs' do
        expect { result }.to change { company.reload.config.default_vat_rate }.to(0.3)
      end
    end

    context 'with invalid parameters' do
      let(:params) { { name: '' } }

      it { is_expected.to be_failure }
    end

    context 'when company does not exist' do
      let(:company_id) { -1 }

      it { is_expected.to be_failure }
    end

    context 'when company have no config' do
      let(:company) { FactoryBot.create(:company) }

      it { is_expected.to be_failure }
    end

    context 'when something goes wrong during the transaction' do
      let(:params) do
        {
          name: 'Valid Name',
          configs: { general_terms_and_conditions: 17 } # We only accept value between 0 and 1 in the database
        }
      end

      it 'rolls back all changes if any update fails' do
        original_name = company.name

        result

        expect(result).to be_failure
        expect(company.reload.name).to eq(original_name)
      end
    end
  end
end
