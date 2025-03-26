require 'rails_helper'

RSpec.describe Organization::Client, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:company).class_name("Organization::Company") }
  end

  describe "validations" do
    subject { FactoryBot.build(:client) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:registration_number) }
    it { is_expected.to validate_presence_of(:vat_number) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:phone) }
    it { is_expected.to validate_presence_of(:address_street) }
    it { is_expected.to validate_presence_of(:address_city) }
    it { is_expected.to validate_presence_of(:address_zipcode) }

    it { is_expected.to allow_value("test@example.com").for(:email) }
    it { is_expected.not_to allow_value("invalid_email").for(:email) }

    it { is_expected.to allow_value("+33612345678").for(:phone) }
    it { is_expected.not_to allow_value("invalid_phone").for(:phone) }

    describe "uniqueness of registration_number scoped on company_id" do
      subject { FactoryBot.build(:client, registration_number: already_existing_client.registration_number, company:) }

      let(:company) { FactoryBot.create(:company) }
      let!(:already_existing_client) { FactoryBot.create(:client, company:) }


      it { is_expected.to validate_uniqueness_of(:registration_number).scoped_to(:company_id) }
    end

    describe "uniqueness of name scoped on company_id" do
      subject { FactoryBot.build(:client, name: already_existing_client.name, company:) }

      let(:company) { FactoryBot.create(:company) }
      let!(:already_existing_client) { FactoryBot.create(:client, company:) }


      it { is_expected.to validate_uniqueness_of(:name).scoped_to(:company_id) }
    end
  end
end
