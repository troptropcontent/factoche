require 'rails_helper'

RSpec.describe Organization::ItemGroup, type: :model do
  subject { FactoryBot.create(:item_group, project_version: project_version, name: item_group_name) }

  let(:company) { FactoryBot.create(:company) }
  let(:client) { FactoryBot.create(:client, company:) }
  let(:project) { FactoryBot.create(:project, client: client) }
  let(:project_version) { FactoryBot.create(:project_version, project: project) }
  let(:item_group_name) { "my_first_item_group" }


  describe "associations" do
    it { is_expected.to belong_to(:project_version).class_name("Organization::ProjectVersion") }
    it { is_expected.to have_many(:grouped_items).class_name("Organization::Item") }
  end

  describe "nested attributes" do
    it { is_expected.to accept_nested_attributes_for(:grouped_items) }
  end

  describe "validations" do
    describe "uniqueness of name scoped to project_version_id" do
      subject { FactoryBot.build(:item_group, project_version: project_version, name: item_group_name) }

      before { FactoryBot.create(:item_group, project_version: project_version, name: item_group_name) }

      it { is_expected.to validate_uniqueness_of(:name).scoped_to(:project_version_id) }
    end
  end
end
