require "rails_helper"

module Accounting
  module Invoices
    RSpec.describe FindNextAvailableUnpublishedNumber do
      describe ".call" do
        let(:company_id) { 1 }
        let(:issue_date) { Time.new(2024, 3, 20) }

        context "when successful" do
          it "generates the first invoice number when no unpublished invoices exist", :aggregate_failures do
            result = described_class.call(company_id, issue_date)

            expect(result).to be_success
            expect(result.data).to eq("PRO-2024-000001")
          end

          it "generates the next invoice number based on existing unpublished invoices", :aggregate_failures do
            # unpublished invoices
            FactoryBot.create(:invoice, company_id: 1, holder_id: 1, number: "PRO-2024-00001", issue_date: issue_date - 2.days)
            FactoryBot.create(:invoice, :voided, company_id: 1, holder_id: 1, number: "PRO-2024-00002", issue_date: issue_date - 2.days)
            # published invoices
            FactoryBot.create(:invoice, :posted, company_id: 1, holder_id: 1, number: "INV-2024-00001", issue_date: issue_date - 2.days)
            FactoryBot.create(:invoice, :cancelled, company_id: 1, holder_id: 1, number: "INV-2024-00002", issue_date: issue_date - 2.days)

            result = described_class.call(company_id, issue_date)

            expect(result).to be_success
            expect(result.data).to eq("PRO-2024-000003")
          end

          it "only counts invoices for the specified company", :aggregate_failures do
            # unpublished invoices for the company id
            FactoryBot.create(:invoice, company_id: 1, holder_id: 1, number: "PRO-2024-00001", issue_date: issue_date - 2.days)
            FactoryBot.create(:invoice, :voided, company_id: 1, holder_id: 1, number: "PRO-2024-00002", issue_date: issue_date - 2.days)
            # unpublished invoices for anpother company id
            FactoryBot.create(:invoice, company_id: 2, holder_id: 1, number: "PRO-2024-00001", issue_date: issue_date - 2.days)
            FactoryBot.create(:invoice, :voided, company_id: 2, holder_id: 1, number: "PRO-2024-00002", issue_date: issue_date - 2.days)

            result = described_class.call(company_id, issue_date)

            expect(result).to be_success
            expect(result.data).to eq("PRO-2024-000003")
          end

          it "uses the provided issue date for the year", :aggregate_failures do
            future_date = Time.new(2025, 1, 1)
            result = described_class.call(company_id, future_date)

            expect(result).to be_success
            expect(result.data).to eq("PRO-2025-000001")
          end

          it "reset counter every year", :aggregate_failures do
            # unpublished invoice from last year
            FactoryBot.create(:invoice, company_id: 1, holder_id: 1, number: "PRO-2024-00001", issue_date: issue_date - 2.days)

            future_date = Time.new(2025, 1, 1)
            result = described_class.call(company_id, future_date)

            expect(result).to be_success
            expect(result.data).to eq("PRO-2025-000001")
          end
        end

        context "when an error occurs" do
          it "returns a failure result", :aggregate_failures do
            allow(Invoice).to receive(:unpublished).and_raise(StandardError.new("Database error"))

            result = described_class.call(company_id, issue_date)

            expect(result).to be_failure
            expect(result.error).to eq("Failed to find next available unpublished invoice number: Database error")
          end
        end
      end
    end
  end
end
