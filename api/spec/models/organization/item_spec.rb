require 'rails_helper'

RSpec.describe Organization::Item, type: :model do
  let(:company) { FactoryBot.create(:company) }
  let(:client) { FactoryBot.create(:client, company:) }
  let(:project) { FactoryBot.create(:project, client: client) }
  let(:project_version) { FactoryBot.create(:project_version, project: project) }
  let(:item_name) { "super_item" }

  subject { FactoryBot.build(:item, holder: project_version, name: item_name) }

  describe "associations" do
    it { should belong_to(:holder) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    describe "uniqueness of name scoped to holder_type and holder_id" do
      before do
        FactoryBot.create(:item, holder: project_version, name: item_name)
      end
      it { should validate_uniqueness_of(:name).scoped_to([ :holder_type, :holder_id ]) }
    end

    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:unit) }
    it { should validate_presence_of(:unit_price_cents) }

    it "validates only allowed holder types" do
      subject.holder_type = "Organization::Company"
      expect(subject).not_to be_valid
    end
  end

  describe "constants" do
    it "defines valid holder types" do
      expect(Organization::Item::VALID_HOLDER_TYPES).to eq([
        "Organization::ItemGroup",
        "Organization::ProjectVersion"
      ])
    end
  end

  describe ".amount_cents" do
    subject { FactoryBot.create(:item, holder: project_version, name: item_name, quantity: 2, unit_price_cents: 123) }
    it "returns unit_price_cents * quantity" do
      expect(subject.amount_cents).to eq(246)
    end
  end
end
