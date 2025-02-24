require 'rails_helper'
require "support/shared_contexts/organization/a_company_with_a_project_with_three_item_groups"

RSpec.describe Organization::CreateCompletionSnapshot do
  describe '.call' do
    include_context 'a company with a project with three item groups'

    it "should create a new completion snapshot and its associated invoice"
  end
end
