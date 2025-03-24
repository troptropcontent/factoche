require 'rails_helper'

RSpec.describe Accounting::FinancialTransactions::FindNextAvailableNumber do
  describe '.call', :aggregate_failures do
    let(:company_id) { 1 }
    let(:another_company_id) { 2 }
    let(:issue_date) { Time.new(2024, 3, 20) }
    let(:prefix) { "INV" }

    context 'when successful' do
      it 'generates first number when no invoices exist' do
        result = described_class.call(
          company_id: company_id,
          prefix: prefix,
          issue_date: issue_date
        )

        expect(result).to be_success
        expect(result.data).to eq("INV-2024-000001")
      end

      it 'generates sequential numbers based on existing invoices' do
        FactoryBot.create(:invoice, :posted, company_id: company_id, holder_id: 1, number: "INV-2024-00001", issue_date: issue_date - 2.days)
        FactoryBot.create(:invoice, :posted, company_id: company_id, holder_id: 1, number: "INV-2024-00002", issue_date: issue_date - 2.days)
        FactoryBot.create(:invoice, :posted, company_id: company_id, holder_id: 1, number: "INV-2024-00003", issue_date: issue_date - 2.days)

        result = described_class.call(
          company_id: company_id,
          prefix: prefix,
          issue_date: issue_date
        )

        expect(result).to be_success

        expect(result.data).to eq("INV-2024-000004")
      end

      it 'only counts invoices from the same year' do
        FactoryBot.create(:invoice, :posted, company_id: company_id, holder_id: 1, number: "INV-2023-00001", issue_date: issue_date.last_year)
        FactoryBot.create(:invoice, :posted, company_id: company_id, holder_id: 1, number: "INV-2024-00001", issue_date: issue_date - 2.days)

        result = described_class.call(
          company_id: company_id,
          prefix: prefix,
          issue_date: issue_date
        )

        expect(result).to be_success
        expect(result.data).to eq("INV-2024-000002")
      end

      it 'only counts invoices with matching prefix' do
        invoice = FactoryBot.create(:invoice, :posted, company_id: company_id, holder_id: 1, number: "INV-2023-00001", issue_date: issue_date.last_year)
        FactoryBot.create(:credit_note, :posted, company_id: company_id, holder_id: 1, number: "CN-2023-00001", invoice: invoice, issue_date: issue_date - 2.days)

        result = described_class.call(
          company_id: company_id,
          prefix: prefix,
          issue_date: issue_date
        )

        expect(result).to be_success
        expect(result.data).to eq("INV-2024-000001")
      end

      it 'only counts invoices for the specified company' do
        FactoryBot.create(:invoice, :posted, company_id: another_company_id, holder_id: 2, number: "INV-2024-00001", issue_date: issue_date - 2.days)


        result = described_class.call(
          company_id: company_id,
          prefix: prefix,
          issue_date: issue_date
        )

        expect(result).to be_success
        expect(result.data).to eq("INV-2024-000001")
      end
    end

    context 'when invalid parameters' do
      context 'with blank company_id' do
        it 'returns failure' do
          result = described_class.call(
            company_id: nil,
            prefix: prefix,
            issue_date: issue_date
          )

          expect(result).to be_failure
          expect(result.error).to include("Company ID is required")
        end
      end

      context 'with blank prefix' do
        it 'returns failure' do
          result = described_class.call(
            company_id: company_id,
            prefix: nil,
            issue_date: issue_date
          )

          expect(result).to be_failure
          expect(result.error).to include("Prefix is required")
        end
      end
    end

    context 'when database error occurs' do
      before do
        allow(Accounting::FinancialTransaction).to receive(:where).and_raise(ActiveRecord::StatementInvalid)
      end

      it 'returns failure' do
        result = described_class.call(
          company_id: company_id,
          prefix: prefix,
          issue_date: issue_date
        )

        expect(result).to be_failure
        expect(result.error).to include("Failed to find next available number")
      end
    end
  end
end
