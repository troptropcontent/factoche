require 'rails_helper'

RSpec.describe Organization::Company, type: :model do
  describe 'validations' do
    context 'phone number' do
      subject { described_class.new }
      it { is_expected.to validate_presence_of(:phone) } #
      it { is_expected.to allow_value('+33607053868').for(:phone) }
      it { is_expected.to allow_value('0607053868').for(:phone) }
      it { is_expected.not_to allow_value('not-a-phone-number').for(:phone) }
      it { is_expected.not_to allow_value('123').for(:phone) }
    end
    context 'email' do
      subject { described_class.new }
      it { is_expected.to allow_value('test@example.com').for(:email) }
      it { is_expected.to allow_value('test.name@example.co.uk').for(:email) }
      it { is_expected.not_to allow_value('invalid-email').for(:email) }
      it { is_expected.not_to allow_value('test@').for(:email) }
      it { is_expected.not_to allow_value('@example.com').for(:email) }
      it 'validates uniqueness of email' do
        subject { FactoryBot.build(:organization_company, email: "already@email.com") }
        FactoryBot.create(:organization_company, email: "already@email.com")
        is_expected.to validate_uniqueness_of(:email)
      end
    end
    context 'name' do
      subject { described_class.new }
      it { is_expected.to validate_presence_of(:name) }
    end
    context 'address fields' do
      subject { described_class.new }
      it { is_expected.to validate_presence_of(:address_street) }
      it { is_expected.to validate_presence_of(:address_city) }
      it { is_expected.to validate_presence_of(:address_zipcode) }
    end
  end
end
