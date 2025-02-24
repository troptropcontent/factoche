require 'rails_helper'

RSpec.describe Organization::Invoice, type: :model do
  subject { FactoryBot.create(:invoice, completion_snapshot: completion_snapshot) }

  let(:company) { FactoryBot.create(:company) }
  let(:client) { FactoryBot.create(:client, company: company) }
  let(:project) { FactoryBot.create(:project, client: client) }
  let(:project_version) { FactoryBot.create(:project_version, project: project) }
  let(:completion_snapshot) { FactoryBot.create(:completion_snapshot, project_version: project_version) }

  describe "associations" do
    it { is_expected.to belong_to(:completion_snapshot).class_name("Organization::CompletionSnapshot") }
    it { is_expected.to have_one_attached(:pdf) }
    it { is_expected.to have_one_attached(:xml) }
    it { is_expected.to have_one(:credit_note).class_name("Organization::CreditNote").with_foreign_key(:original_invoice_id).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_numericality_of(:total_excl_tax_amount).is_greater_than_or_equal_to(0) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:status).backed_by_column_of_type(:enum).with_values(draft: "draft", published: "published", cancelled: "cancelled").with_default(:draft) }
  end
end
