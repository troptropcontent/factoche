require 'rails_helper'

RSpec.describe Accounting::FinancialTransactionDetail, type: :model do
  subject(:detail) { FactoryBot.build(:financial_transaction_detail) }

  describe "associations" do
    it { is_expected.to belong_to(:financial_transaction).class_name("Accounting::FinancialTransaction") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:delivery_date) }
    it { is_expected.to validate_presence_of(:seller_name) }
    it { is_expected.to validate_presence_of(:seller_registration_number) }
    it { is_expected.to validate_presence_of(:seller_address_zipcode) }
    it { is_expected.to validate_presence_of(:seller_address_street) }
    it { is_expected.to validate_presence_of(:seller_address_city) }
    it { is_expected.to validate_presence_of(:seller_vat_number) }
    it { is_expected.to validate_presence_of(:client_name) }
    it { is_expected.to validate_presence_of(:client_registration_number) }
    it { is_expected.to validate_presence_of(:client_address_zipcode) }
    it { is_expected.to validate_presence_of(:client_address_street) }
    it { is_expected.to validate_presence_of(:client_address_city) }
    it { is_expected.to validate_presence_of(:client_vat_number) }
    it { is_expected.to validate_presence_of(:delivery_name) }
    it { is_expected.to validate_presence_of(:delivery_registration_number) }
    it { is_expected.to validate_presence_of(:delivery_address_zipcode) }
    it { is_expected.to validate_presence_of(:delivery_address_street) }
    it { is_expected.to validate_presence_of(:delivery_address_city) }
    it { is_expected.to validate_presence_of(:purchase_order_number) }
    it { is_expected.to validate_presence_of(:due_date) }
  end
end
