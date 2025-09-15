require 'rails_helper'

RSpec.describe Organization::BankDetail, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:company).class_name("Organization::Company") }
  end

  describe "validations" do
    subject { FactoryBot.build(:bank_detail) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:iban) }
    it { is_expected.to validate_presence_of(:bic) }

    describe "uniqueness of name scoped on company_id" do
      subject { FactoryBot.build(:bank_detail, name: already_existing_bank_detail.name, company:) }

      let(:company) { FactoryBot.create(:company) }
      let!(:already_existing_bank_detail) { FactoryBot.create(:bank_detail, company:) }

      it { is_expected.to validate_uniqueness_of(:name).scoped_to(:company_id) }
    end

    describe "uniqueness of iban scoped on company_id" do
      subject { FactoryBot.build(:bank_detail, iban: already_existing_bank_detail.iban, company:) }

      let(:company) { FactoryBot.create(:company) }
      let!(:already_existing_bank_detail) { FactoryBot.create(:bank_detail, company:) }

      it { is_expected.to validate_uniqueness_of(:iban).scoped_to(:company_id) }
    end
  end
end
