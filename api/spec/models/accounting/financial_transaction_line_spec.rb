require 'rails_helper'
require 'support/shared_contexts/organization/projects/a_company_with_an_order'
RSpec.describe Accounting::FinancialTransactionLine, type: :model do
  include_context 'a company with an order'

  describe 'associations' do
    it { is_expected.to belong_to(:financial_transaction).class_name('Accounting::FinancialTransaction') }
  end

  describe 'validations' do
    subject(:line) {
      FactoryBot.build(:financial_transaction_line, financial_transaction_id: invoice.id)
    }

    let(:invoice) {
      proforma = Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data
      Accounting::Proformas::Post.call(proforma.id).data
    }


    it { is_expected.to validate_presence_of(:unit) }
    it { is_expected.to validate_presence_of(:unit_price_amount) }
    it { is_expected.to validate_presence_of(:quantity) }
    it { is_expected.to validate_presence_of(:tax_rate) }
    it { is_expected.to validate_presence_of(:excl_tax_amount) }

    it { is_expected.to validate_numericality_of(:unit_price_amount).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:quantity).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:excl_tax_amount).is_greater_than_or_equal_to(0) }

    it { is_expected.to validate_numericality_of(:tax_rate).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(1) }

    it do
      expect(line).to validate_uniqueness_of(:holder_id)
        .scoped_to(:financial_transaction_id)
        .with_message('has already been taken for this financial transaction')
    end

    describe "excl_tax_amount" do
      context "when excl_tax_amount is equal to quantity * unit_price" do
        before {
          line.unit_price_amount = 123
          line.quantity = 3
          line.excl_tax_amount = 369
        }

        it { is_expected.to be_valid }
      end

      context "when excl_tax_amount is not equal to quantity * unit_price" do
        before {
          line.unit_price_amount = 123
          line.quantity = 4
          line.excl_tax_amount = 369
        }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
