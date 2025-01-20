require 'rails_helper'

RSpec.describe Organization::ItemGroup, type: :model do
  let(:company) { FactoryBot.create(:company) }
  let(:client) { FactoryBot.create(:client, company:) }
  let(:project) { FactoryBot.create(:project, client: client) }
  let(:project_version) { FactoryBot.create(:project_version, project: project) }
  let(:item_group_name) { "my_first_item_group" }
  subject { FactoryBot.create(:item_group, project_version: project_version, name: item_group_name) }

  describe "associations" do
    it { should belong_to(:project_version).class_name("Organization::ProjectVersion") }
    it { should have_many(:items).class_name("Organization::Item") }
  end

  describe "nested attributes" do
    it { should accept_nested_attributes_for(:items) }
  end

  describe "validations" do
    describe "uniqueness of name scoped to project_version_id" do
      before {
        subject { FactoryBot.create(:item_group, project_version: project_version, name: item_group_name) }
      }
      it { should validate_uniqueness_of(:name).scoped_to(:project_version_id) }
    end
  end
end
