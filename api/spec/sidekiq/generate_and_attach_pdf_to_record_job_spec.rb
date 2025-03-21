require 'rails_helper'
require "support/shared_contexts/organization/a_company_with_a_project_with_three_items"
# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe GenerateAndAttachPdfToRecordJob do
  describe '#perform' do
    include_context 'a company with a project with three items'

    let(:pdf_file) { Tempfile.new([ 'test', '.pdf' ]) }
    let(:record) { quote_version }
    let(:id) { record.id }
    let(:class_name) { "Organization::ProjectVersion" }
    let(:file_name) { "DEV-#{quote.number}-#{quote_version.number}" }
    let(:args) {
      {
        "url"=> "url",
        "class_name"=> class_name,
        "id"=> id,
        "file_name"=> file_name
      }
    }

    before do
      allow(HeadlessBrowserPdfGenerator).to receive(:call)
        .and_return(pdf_file)
    end

    after do
      pdf_file.close
      pdf_file.unlink
    end

    it 'generates and attaches PDF to the record' do
      expect {
        described_class.new.perform(args)
      }.to change { record.reload.pdf.attached? }.from(false).to(true)
    end

    context "when the class is not a descendant of ActiveRecord::Base" do
      let(:class_name) { "String" }

      it 'raises an error' do
        expect {
        described_class.new.perform(args)
      }.to raise_error("Class must inherit from ActiveRecord::Base")
      end
    end

    context 'when record is not found' do
      let(:id) { -1 }

      it 'raises a RecordNotFound error' do
        expect {
          described_class.new.perform(args)
        }.to raise_error(ActiveRecord::RecordNotFound, "Couldn't find Organization::ProjectVersion with 'id'=-1")
      end
    end

    context "when the headless browser fails" do
      before do
        allow(HeadlessBrowserPdfGenerator).to receive(:call)
          .and_raise(Error::UnprocessableEntityError, "Headless Browser Error")
      end

      it 'raises a RecordNotFound error' do
        expect {
          described_class.new.perform(args)
        }.to raise_error(Error::UnprocessableEntityError, "Headless Browser Error")
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
