require 'rails_helper'
require "support/shared_contexts/organization/a_company_with_a_project_with_three_items"

RSpec.describe Organization::ProjectVersions::GeneratePdfJob, type: :job do
  include_context 'a company with a project with three items'
  describe '#perform' do
    let(:version) { quote_version }
    let(:pdf_job_args) { { "url" => "http://example.com", "class_name" => "ProjectVersion", "id" => version.id, "file_name" => "version.pdf" } }

    before do
      allow(Organization::ProjectVersion).to receive(:find).with(version.id).and_return(version)
      allow(Organization::ProjectVersions::BuildPdfJobArguments).to receive(:call).with(version).and_return(ServiceResult.success(pdf_job_args))
    end

    context 'when successful' do
      it 'enqueues the GenerateAndAttachPdfToRecordJob with correct arguments', :aggregate_failures do
        expect { described_class.new.perform("project_version_id" => version.id) }.to change(GenerateAndAttachPdfToRecordJob.jobs, :size).by(1)
        expect(GenerateAndAttachPdfToRecordJob.jobs.last["args"]).to include(pdf_job_args)
      end
    end

    context 'when building pdf job arguments fails' do
      before do
        allow(Organization::ProjectVersions::BuildPdfJobArguments).to receive(:call).with(version).and_return(ServiceResult.failure('Error'))
      end

      it 'raises an UnprocessableEntityError' do
        expect {
          described_class.new.perform("project_version_id" => version.id)
        }.to raise_error(Error::UnprocessableEntityError, "Failed to build pdf job args")
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow(Organization::ProjectVersion).to receive(:find).and_raise(StandardError, 'Unexpected error')
      end

      it 'raises the error' do
        expect {
          described_class.new.perform("project_version_id" => version.id)
        }.to raise_error(StandardError, 'Unexpected error')
      end
    end
  end
end
