require 'rails_helper'

module Tests
  class TestInvoice < Accounting::FinancialTransaction
    class Context < Dry::Validation::Contract
      params do
        required(:test_field).filled(:string)
        required(:amount).filled(:decimal, gteq?: 0)
      end
    end
  end

  class TestCreditNote < Accounting::FinancialTransaction
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
      subject(:transaction) { Tests::TestInvoice.new(context: context) }

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

    describe "number" do
      subject(:transaction) { Tests::TestInvoice.new(company_id: 1, status: status, number: number) }

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

          before do
            FactoryBot.create(
              :completion_snapshot_invoice,
              company_id: 1,
              status: :posted,
              holder_id: FactoryBot.create(:company).id,
              number: number
            )
            transaction.valid?
          end

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

  describe "enums" do
    context "when the class ends with Invoice" do
      subject(:transaction) { Tests::TestInvoice.new }

      it "define an enum with draft, posted, and cancell staus" do
        expect(transaction).to define_enum_for(:status)
          .backed_by_column_of_type(:enum)
          .with_values(draft: "draft", posted: "posted", cancelled: "cancelled")
          .with_default(:draft)
      end
    end

    context "when the class does not ends with Invoice" do
      subject(:transaction) { Tests::TestCreditNote.new }

      it "define an enum with draft and posted staus" do
        expect(transaction).to define_enum_for(:status)
          .backed_by_column_of_type(:enum)
          .with_values(draft: "draft", posted: "posted")
          .with_default(:draft)
      end
    end
  end
end
