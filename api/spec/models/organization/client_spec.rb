require 'rails_helper'

RSpec.describe Organization::Client, type: :model do
  describe "associations" do
    it { should belong_to(:company).class_name("Organization::Company") }
  end

  describe "validations" do
    subject { FactoryBot.build(:client) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:registration_number) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:phone) }
    it { should validate_presence_of(:address_street) }
    it { should validate_presence_of(:address_city) }
    it { should validate_presence_of(:address_zipcode) }

    it { should allow_value("test@example.com").for(:email) }
    it { should_not allow_value("invalid_email").for(:email) }

    it { should allow_value("+33612345678").for(:phone) }
    it { should_not allow_value("invalid_phone").for(:phone) }
    describe "uniqueness of registration_number scoped on company_id", focus: true do
      let(:company) { FactoryBot.create(:company) }
      let!(:already_existing_client) { FactoryBot.create(:client, company:) }
      subject { FactoryBot.build(:client, registration_number: already_existing_client.registration_number, company:) }
      it { should validate_uniqueness_of(:registration_number).scoped_to(:company_id) }
    end
  end
end
