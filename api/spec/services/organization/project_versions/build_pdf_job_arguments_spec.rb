require 'rails_helper'
require "support/shared_contexts/organization/a_company_with_a_project_with_three_items"

RSpec.describe Organization::ProjectVersions::BuildPdfJobArguments do
  describe '.call' do
    subject(:result) { described_class.call(version) }

    include_context 'a company with a project with three items'
    let(:version) { quote_version }
    let(:version_identifier) { 'PRJ-001-0001' }
    let(:host) { 'http://example.com' }

    before do
      allow(Rails.configuration.headless_browser).to receive(:fetch).with(:app_host).and_return(host)
      allow(Organization::ProjectVersions::BuildVersionNumber).to receive(:call).and_return(ServiceResult.success(version_identifier))
    end

    context 'when successful' do
      it 'returns a success result with correct arguments', :aggregate_failures do
        result = described_class.call(version)

        expect(result).to be_success
        expect(result.data).to include(
          "url" => "http://example.com/prints/quotes/#{version.project.id}/quote_versions/#{version.id}",
          "class_name" => version.class.name,
          "id" => version.id,
          "file_name" => "#{version_identifier}"
        )
      end
    end

    context 'when version number computation fails' do
      before do
        allow(Organization::ProjectVersions::BuildVersionNumber).to receive(:call).and_return(ServiceResult.failure('Error'))
      end

      it 'returns a failure result', :aggregate_failures do
        expect(result).to be_failure

        expect(result.error.message).to eq('Failed to compute version number')
      end
    end

    context 'when headless browser config are not set' do
      before do
        allow(Rails.configuration).to receive(:headless_browser).and_return(nil)
      end

      it 'returns a failure result' do
        expect(result).to be_failure
      end
    end
  end
end
