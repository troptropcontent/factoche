require 'rails_helper'
require 'support/shared_contexts/organization/projects/a_company_with_some_orders'

RSpec.describe Organization::Invoices::FindNextSnapshotNumber do
  describe '.call' do
    include_context 'a company with some orders', number_of_orders: 2
    let(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }

    context 'when there are no existing invoices for the order' do
      it 'returns 1 as the next snapshot number', :aggregate_failures do
        result = described_class.call(first_order.id)
        expect(result).to be_success
        expect(result.data).to eq(1)
      end
    end

    context 'when there are existing invoices for the order' do
      before do
        3.times do |n|
          FactoryBot.create(:invoice,
            holder_id: first_order.versions.first.id,
            company_id: company.id,
            number: "INV-#{Time.current.year}-#{Time.current.month.to_s.rjust(2, "0")}-00000#{n}",
            status: :posted,
            client_id: first_client.id,
            financial_year: financial_year)
        end
      end

      it 'returns the count of existing invoices + 1', :aggregate_failures do
        result = described_class.call(first_order.id)
        expect(result).to be_success
        expect(result.data).to eq(4)
      end
    end

    context 'when the order has multiple versions with invoices' do
      let(:another_order_version) { FactoryBot.create(:project_version, project: first_order) }

      before do
        2.times do |n|
          FactoryBot.create(:invoice,
            holder_id: first_order.versions.first.id,
            company_id: company.id,
            number: "INV-#{Time.current.year}-#{Time.current.month.to_s.rjust(2, "0")}-00000#{n}",
            status: :posted,
            client_id: first_client.id,
            financial_year: financial_year)
        end

        FactoryBot.create(:invoice,
            holder_id: another_order_version.id,
            company_id: company.id,
            number: "INV-#{Time.current.year}-#{Time.current.month.to_s.rjust(2, "0")}-000003",
            status: :posted,
            client_id: first_client.id,
            financial_year: financial_year)
      end

      it 'counts all invoices across all order versions', :aggregate_failures do
        result = described_class.call(first_order.id)
        expect(result).to be_success
        expect(result.data).to eq(4)
      end
    end

    context 'when invoices exist for other orders' do
      before do
        FactoryBot.create(:invoice,
            holder_id: first_order.versions.first.id,
            company_id: company.id,
            number: "INV-#{Time.current.year}-#{Time.current.month.to_s.rjust(2, "0")}-000001",
            status: :posted,
            client_id: first_client.id,
            financial_year: financial_year)

        FactoryBot.create(:invoice,
            holder_id: second_order.versions.first.id,
            company_id: company.id,
            number: "INV-#{Time.current.year}-#{Time.current.month.to_s.rjust(2, "0")}-000002",
            status: :posted,
            client_id: first_client.id,
            financial_year: financial_year)
      end

      it 'only counts invoices for the specified order', :aggregate_failures do
        result = described_class.call(first_order.id)
        expect(result).to be_success
        expect(result.data).to eq(2)
      end
    end

    context 'when the order does not exist' do
      it 'returns a failure result', :aggregate_failures do
        result = described_class.call(999999)
        expect(result).to be_failure
        expect(result.error).to be_a(ActiveRecord::RecordNotFound)
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow(::Organization::Order).to receive(:find).and_raise(StandardError, "Unexpected error")
      end

      it 'returns a failure result', :aggregate_failures do
        result = described_class.call(first_order.id)
        expect(result).to be_failure
        expect(result.error.message).to eq("Unexpected error")
      end
    end
  end
end
