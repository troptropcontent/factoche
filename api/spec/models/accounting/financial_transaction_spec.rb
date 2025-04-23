require 'rails_helper'
require 'support/shared_contexts/organization/projects/a_company_with_an_order'

module Tests
  class Invoice < Accounting::FinancialTransaction
    class Context < Dry::Validation::Contract
      params do
        required(:test_field).filled(:string)
        required(:amount).filled(:decimal, gteq?: 0)
      end
    end
  end

  class CreditNote < Accounting::FinancialTransaction
    class Context < Dry::Validation::Contract
      params do
        required(:test_field).filled(:string)
        required(:amount).filled(:decimal, gteq?: 0)
      end
    end
  end
end

RSpec.describe Accounting::FinancialTransaction, type: :model do
  describe "validation" do
    describe "context" do
      subject(:transaction) { Tests::Invoice.new(context: context, number: "INV-2024-0001") }

      context 'when context is valid' do
        let(:context) do
          {
            test_field: 'test',
            amount: '100.00'
          }
        end

        it "does not return an error for the context attribute" do
          transaction.valid?
          expect(transaction.errors["context"]).to be_empty
        end
      end

      context 'when context is invalid' do
        let(:context) do
          {
            test_field: '',
            amount: '-10.00'
          }
        end

        it "does return an error for the context attribute" do
          transaction.valid?
          expect(transaction.errors["context"]).not_to be_empty
        end

        it 'adds appropriate error messages' do
          transaction.valid?
          expect(transaction.errors[:context]).to include(
            'test_field must be filled',
            'amount must be greater than or equal to 0'
          )
        end
      end

      context 'when context is empty hash' do
        let(:context) { {} }

        it "returns an error for the context attribute" do
          transaction.valid?
          expect(transaction.errors["context"]).not_to be_empty
        end
      end
    end

    describe "type" do
      subject(:transaction) {
        proforma = Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data
        Accounting::Proformas::Post.call(proforma.id).data
       }

      include_context 'a company with an order'


      context "when the type is Invoice" do
        it { is_expected.to be_valid }
      end

      context "when the type is CreditNote" do
        before { transaction.type = "CreditNote" }

        it { is_expected.to be_valid }
      end

      context "when the type is Proforma" do
        before { transaction.type = "Proforma" }

        it { is_expected.to be_valid }
      end

      context "when the type is not CreditNote or Invoice" do
        before { transaction.type = "SomeOtherTypeName" }

        it { is_expected.not_to be_valid }

        it "returns a proper message" do
          transaction.valid?
          expect(transaction.errors["type"]).to include("must either be Invoice, CreditNote or Proforma")
        end
      end
    end
  end
end
