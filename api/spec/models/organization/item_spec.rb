require 'rails_helper'

RSpec.describe Organization::Item, type: :model do
  let(:company) { FactoryBot.create(:company) }
  let(:client) { FactoryBot.create(:client, company:) }
  let(:project) { FactoryBot.create(:project, client: client) }
  let(:project_version) { FactoryBot.create(:project_version, project: project) }
  let(:item_name) { "super_item" }

  subject { FactoryBot.build(:item, project_version: project_version, name: item_name) }

  describe "associations" do
    it { should belong_to(:project_version) }
    it { should belong_to(:item_group).optional }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    describe "uniqueness of name scoped to project_version_id and item_group_id" do
      context "when the record does not belong to a item_group" do
        let!(:already_existing_item) { FactoryBot.create(:item, project_version: project_version, name: item_name) }
        it { should validate_uniqueness_of(:name).scoped_to([ :project_version_id, :item_group_id ]) }
      end
      context "when the record belongs to a item_group" do
        subject { FactoryBot.build(:item, project_version: project_version, item_group: item_group, name: item_name) }
        let(:item_group) { FactoryBot.create(:item_group, project_version: project_version) }
        let!(:already_existing_item) { FactoryBot.create(:item, project_version: project_version, item_group: item_group, name: item_name) }

        it { should validate_uniqueness_of(:name).scoped_to([ :project_version_id, :item_group_id ]) }
      end
    end

    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:unit) }
    it { should validate_presence_of(:unit_price_cents) }

    describe "item_group_belongs_to_same_project_version" do
      let(:item_group) { FactoryBot.create(:item_group, project_version: project_version) }
      let(:other_project_version) { FactoryBot.create(:project_version, project: project) }
      let(:other_item_group) { FactoryBot.create(:item_group, project_version: other_project_version) }

      context "when item_group is nil" do
        subject { FactoryBot.build(:item, project_version: project_version, item_group: nil) }
        it { should be_valid }
      end

      context "when item_group belongs to the same project_version" do
        subject { FactoryBot.build(:item, project_version: project_version, item_group: item_group) }
        it { should be_valid }
      end

      context "when item_group belongs to a different project_version" do
        subject { FactoryBot.build(:item, project_version: project_version, item_group: other_item_group) }
        it { should_not be_valid }

        it "adds the correct error message" do
          subject.valid?
          expect(subject.errors[:item_group]).to include("must belong to the same project version than the item")
        end
      end
    end
  end

  describe ".amount_cents" do
    subject { FactoryBot.create(:item, project_version: project_version, name: item_name, quantity: 2, unit_price_cents: 123) }
    it "returns unit_price_cents * quantity" do
      expect(subject.amount_cents).to eq(246)
    end
  end
end
