require 'rails_helper'

RSpec.describe Accounting::FinancialTransaction, type: :model do
  describe "validation" do
    describe "context" do
      subject(:transaction) { test_transaction_class.new(context: context) }

      let(:test_context) do
        Class.new(Dry::Validation::Contract) do
          params do
            required(:test_field).filled(:string)
            required(:amount).filled(:decimal, gteq?: 0)
          end
        end
      end

      let(:test_transaction_class) do
        context_class = test_context
        Class.new(described_class) do
          def self.name
            'TestTransactionClass'
          end
          const_set(:Context, context_class)
        end
      end

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

      context 'when context is nil' do
        let(:context) { nil }

        it "does return an error for the context attribute" do
          transaction.valid?
          expect(transaction.errors["context"]).not_to be_empty
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

    describe "number" do
      subject(:transaction) { FactoryBot.build(:financial_transaction, company_id: 1, status: status, number: number) }

      let(:status) { :draft }

      let(:number) { nil }

      before { transaction.valid? }

      context "when the transaction is draft" do
        it "is not required" do
          expect(transaction.errors[:number]).to be_empty
        end
      end

      context "when the transaction is not draft" do
        let(:status) { :posted }

        it "is not required" do
          expect(transaction.errors[:number]).to include("can't be blank")
        end

        context "when the number has already been assigned for the company" do
          let(:number) { "INV-2005-0002" }

          before { FactoryBot.create(:completion_snapshot_invoice, company_id: 1, status: :posted, holder_id: FactoryBot.create(:company).id, number: number) && transaction.valid? }

          it "is invalid" do
            expect(transaction.errors[:number]).to include("has already been taken for this company")
          end
        end
      end
    end

    describe "type" do
      subject(:transaction) { FactoryBot.build(:completion_snapshot_invoice, company_id: 2, holder_id: 2) }

      context "when the type ends with Invoice" do
        it { is_expected.to be_valid }
      end

      context "when the type ends with CreditNote" do
        before { transaction.type = "SomeTypeOfCreditNote" }

        it { is_expected.to be_valid }
      end

      context "when the type does not ends with CreditNote or Invoice" do
        before { transaction.type = "SomeOtherTypeName" }

        it { is_expected.not_to be_valid }

        it "returns a proper message" do
          transaction.valid?
          expect(transaction.errors["type"]).to include("must end with Invoice or CreditNote")
        end
      end
    end
  end
end
