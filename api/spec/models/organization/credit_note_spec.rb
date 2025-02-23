require 'rails_helper'

RSpec.describe Organization::CreditNote, type: :model do
  subject { FactoryBot.build(:credit_note, original_invoice: completion_snapshot.invoice) }

  let(:company) { FactoryBot.create(:company, :with_config) }
  let(:client) { FactoryBot.create(:client, company: company) }
  let(:project) { FactoryBot.create(:project, client: client) }
  let(:project_version) { FactoryBot.create(:project_version, project: project) }
  let(:completion_snapshot) { FactoryBot.create(:completion_snapshot, :with_invoice, project_version: project_version) }

  describe "associations" do
    it { is_expected.to belong_to(:original_invoice).class_name("Organization::Invoice") }
    it { is_expected.to have_one_attached(:pdf) }
  end

  describe "validations" do
    it { is_expected.to validate_numericality_of(:total_excl_tax_amount).is_greater_than_or_equal_to(0) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:status).backed_by_column_of_type(:enum).with_values(draft: "draft", published: "published").with_default(:draft) }
  end
end
