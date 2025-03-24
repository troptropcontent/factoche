require 'rails_helper'
require "support/shared_contexts/organization/a_company_with_a_project_with_three_items"
RSpec.describe Organization::ProjectVersions::BuildVersionNumber do
  describe '.call' do
    include_context 'a company with a project with three items'

    context 'when successful' do
      it 'returns a success result with the correct version number', :aggregate_failures do
        result = described_class.call(quote_version)

        expect(result).to be_success
        expect(result.data).to eq('QUO-0001-0001')
      end
    end

    context 'when an error occurs' do
      before do
        allow(quote_version.project).to receive(:number).and_raise(StandardError, 'Unexpected error')
      end

      it 'returns a failure result', :aggregate_failures do
        result = described_class.call(quote_version)

        expect(result).to be_failure
        expect(result.error.message).to eq('Unexpected error')
      end
    end
  end
end
