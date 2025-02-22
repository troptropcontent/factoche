require 'rails_helper'
require_relative "shared_examples/accounting_document_example"

RSpec.describe Organization::Invoice, type: :model do
  subject { FactoryBot.create(:invoice, completion_snapshot: completion_snapshot) }

  let(:company) { FactoryBot.create(:company) }
  let(:client) { FactoryBot.create(:client, company: company) }
  let(:project) { FactoryBot.create(:project, client: client) }
  let(:project_version) { FactoryBot.create(:project_version, project: project) }
  let(:completion_snapshot) { FactoryBot.create(:completion_snapshot, project_version: project_version) }

  it_behaves_like "an accounting document"
end
