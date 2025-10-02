require 'rails_helper'
require 'services/shared_examples/service_result_example'
require 'support/shared_contexts/organization/projects/a_company_with_some_orders'

RSpec.describe Accounting::FinancialYears::Renew do
  describe '#call' do
  subject(:result) { described_class.call(financial_year.id) }

  include_context 'a company with some orders'

  let!(:financial_year) { FactoryBot.create(:financial_year, company_id:, start_date:, end_date:) }
  let(:company_id) { company.id }
  let(:start_date) { DateTime.parse('01-01-2024') }
  let(:end_date) { DateTime.parse('31-12-2024').end_of_day }

  context "when no overlaping exercice exists" do
    let(:expected_start_date) { DateTime.parse('01-01-2025') }
    let(:expected_end_date) { DateTime.parse('31-12-2025').end_of_day }

    it_behaves_like 'a success'


    it "sets the start_date and end_date to the same period next year", :aggregate_failures do
      new_exercice = result.data
      expect(new_exercice.start_date).to be_within(1).of(expected_start_date)
      expect(new_exercice.end_date).to be_within(1).of(expected_end_date)
    end

    it "creates a new financial year" do
      expect { result }.to change(Accounting::FinancialYear, :count).by(1)
    end

      context "when the end_date is on end of february" do
        context "when the current end_date is on 29/02" do
          let(:start_date) { DateTime.parse('01-03-2023') }
          let(:end_date) { DateTime.parse('29-02-2024').end_of_day }
          let(:expected_start_date) { DateTime.parse('01-03-2024') }
          let(:expected_end_date) { DateTime.parse('28-02-2025').end_of_day }

          it "sets end_date to 28/02", :aggregate_failures do
            new_exercice = result.data
            expect(new_exercice.start_date).to be_within(1).of(expected_start_date)
            expect(new_exercice.end_date).to be_within(1).of(expected_end_date)
          end
        end

        context "when the current end_date is on 28/02 but next year is bisextile" do
          let(:start_date) { DateTime.parse('01-03-2022') }
          let(:end_date) { DateTime.parse('28-02-2023').end_of_day }
          let(:expected_start_date) { DateTime.parse('01-03-2023') }
          let(:expected_end_date) { DateTime.parse('29-02-2024').end_of_day }

          it "sets end_date to 29/02", :aggregate_failures do
            new_exercice = result.data
            expect(new_exercice.start_date).to be_within(1).of(expected_start_date)
            expect(new_exercice.end_date).to be_within(1).of(expected_end_date)
          end
        end
      end
    end

    context "when the exercice have already been renewed" do
      before do
        FactoryBot.create(:financial_year, company_id:, start_date: start_date.next_year, end_date: end_date.next_year)
      end

      it_behaves_like 'a failure', "Validation failed: dates overlap with existing financial year"

      it "does not creates a new financial year" do
        expect { result }.not_to change(Accounting::FinancialYear, :count)
      end
    end
  end
end
