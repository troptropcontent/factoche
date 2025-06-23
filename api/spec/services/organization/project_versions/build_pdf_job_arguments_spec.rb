require 'rails_helper'
require 'support/shared_contexts/organization/a_company_with_a_project_with_three_items'
require 'support/shared_contexts/organization/projects/a_company_with_an_order'

RSpec.describe Organization::ProjectVersions::BuildPdfJobArguments do
  describe '.call' do
    subject(:result) { described_class.call(version) }

    include_context 'a company with an order'
    let(:version) { quote_version }
    let(:version_identifier) { 'PRJ-001-0001' }
    let(:host) { 'http://example.com' }

    scenarios = [
      { project_class: Organization::Quote, version_identifier: "QUO-001-0001", path: /\/prints\/quotes\/\d+\/quote_versions\/\d+/ },
      { project_class: Organization::DraftOrder, version_identifier: "DRA-001-0001", path: /\/prints\/draft_orders\/\d+\/draft_order_versions\/\d+/ },
      { project_class: Organization::Order, version_identifier: "ORD-001-0001", path: /\/prints\/orders\/\d+\/order_versions\/\d+/ }
    ]

    scenarios.each do |scenario|
      context "when the project is a #{scenario[:project_class]}" do
        let(:version) { scenario[:project_class].last.last_version }

        before do
          allow(Rails.configuration.headless_browser).to receive(:fetch).with(:app_host).and_return(host)
          allow(Organization::ProjectVersions::BuildVersionNumber).to receive(:call).and_return(ServiceResult.success(scenario[:version_identifier]))
        end

        context 'when successful' do
          it 'returns a success result with correct arguments', :aggregate_failures do
            expect(result).to be_success

            expect(result.data).to include(
              "class_name" => version.class.name,
              "id" => version.id,
              "file_name" => scenario[:version_identifier],
              "websocket_channel" => "notifications_company_#{version.project.company_id}"
            )

            url = URI.parse(result.data['url'])
            expect(url.path).to match(scenario[:path])
            expect(url.query).to match(/token=.+/)
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
      end
    end
  end
end
