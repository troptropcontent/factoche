require 'rails_helper'

RSpec.describe Organization::Company, type: :model do
  describe 'validations' do
    describe 'phone number' do
      subject { described_class.new }

      it { is_expected.to validate_presence_of(:phone) } #
      it { is_expected.to allow_value('+33607053868').for(:phone) }
      it { is_expected.to allow_value('0607053868').for(:phone) }
      it { is_expected.not_to allow_value('not-a-phone-number').for(:phone) }
      it { is_expected.not_to allow_value('123').for(:phone) }
    end

    describe 'email' do
      subject { described_class.new }

      it { is_expected.to allow_value('test@example.com').for(:email) }
      it { is_expected.to allow_value('test.name@example.co.uk').for(:email) }
      it { is_expected.not_to allow_value('invalid-email').for(:email) }
      it { is_expected.not_to allow_value('test@').for(:email) }
      it { is_expected.not_to allow_value('@example.com').for(:email) }

      it 'validates uniqueness of email' do
        subject(:company) { FactoryBot.build(:company, email: "already@email.com") }

        FactoryBot.create(:company, email: "already@email.com")
        expect(company).to validate_uniqueness_of(:email)
      end
    end

    describe 'name' do
      subject { described_class.new }

      it { is_expected.to validate_presence_of(:name) }
    end

    describe 'address fields' do
      subject { described_class.new }

      it { is_expected.to validate_presence_of(:address_street) }
      it { is_expected.to validate_presence_of(:address_city) }
      it { is_expected.to validate_presence_of(:address_zipcode) }
    end

    describe 'registration number' do
      subject { described_class.new }

      it { is_expected.to validate_presence_of(:registration_number) }
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:members).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:members) }
    it { is_expected.to have_many(:clients).dependent(:destroy) }
  end
end
