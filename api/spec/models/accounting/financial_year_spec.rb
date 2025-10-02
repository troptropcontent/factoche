require 'rails_helper'

# rubocop:disable RSpec/MultipleExpectations
RSpec.describe Accounting::FinancialYear, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:financial_transactions).class_name('Accounting::FinancialTransaction') }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }

    describe '#dates_consistency' do
      it 'is valid when end_date is after start_date' do
        financial_year = FactoryBot.build(:financial_year,
                                         start_date: DateTime.parse("01-01-2024"),
                                         end_date: DateTime.parse("31-12-2024").end_of_day)
        expect(financial_year).to be_valid
      end

      it 'is invalid when end_date equals start_date' do
        financial_year = FactoryBot.build(:financial_year,
                                         start_date: DateTime.parse("01-01-2024"),
                                         end_date: DateTime.parse("01-01-2024"))
        expect(financial_year).to be_invalid
        expect(financial_year.errors[:end_date]).to include('must be after start date')
      end

      it 'is invalid when end_date is before start_date' do
        financial_year = FactoryBot.build(:financial_year,
                                         start_date: DateTime.parse("31-12-2024"),
                                         end_date: DateTime.parse("01-01-2024").end_of_day)
        expect(financial_year).to be_invalid
        expect(financial_year.errors[:end_date]).to include('must be after start date')
      end
    end

    describe '#no_overlapping_exercises' do
      let(:company) { FactoryBot.create(:company) }
      let!(:existing_fy) { FactoryBot.create(:financial_year,
                                            company_id: company.id,
                                            start_date: DateTime.parse("01-01-2024"),
                                            end_date: DateTime.parse("31-12-2024").end_of_day) }

      it 'allows non-overlapping financial years for same company' do
        new_fy = FactoryBot.build(:financial_year,
                                 company_id: company.id,
                                 start_date: DateTime.parse("01-01-2025"),
                                 end_date: DateTime.parse("31-12-2025").end_of_day)
        expect(new_fy).to be_valid
      end

      it 'allows same dates for different companies' do
        other_company = FactoryBot.create(:company)
        new_fy = FactoryBot.build(:financial_year,
                                 company_id: other_company.id,
                                 start_date: DateTime.parse("01-01-2024"),
                                 end_date: DateTime.parse("31-12-2024").end_of_day)
        expect(new_fy).to be_valid
      end

      it 'rejects when new period starts during existing period' do
        start_date = DateTime.parse("01-06-2024")
        end_date = DateTime.parse("31-05-2025").end_of_day

        new_fy = FactoryBot.build(:financial_year, company_id: company.id, start_date:, end_date:)
        expect(new_fy).to be_invalid
        expect(new_fy.errors[:base]).to include('dates overlap with existing financial year')
      end

      it 'rejects when new period ends during existing period' do
        new_fy = FactoryBot.build(:financial_year,
                                 company_id: company.id,
                                 start_date: DateTime.parse("01-06-2023"),
                                 end_date: DateTime.parse("31-05-2024").end_of_day)
        expect(new_fy).to be_invalid
        expect(new_fy.errors[:base]).to include('dates overlap with existing financial year')
      end

      it 'rejects when new period encompasses existing period' do
        new_fy = FactoryBot.build(:financial_year,
                                 company_id: company.id,
                                 start_date: DateTime.parse("01-01-2023"),
                                 end_date: DateTime.parse("31-12-2025").end_of_day)
        expect(new_fy).to be_invalid
        expect(new_fy.errors[:base]).to include('dates overlap with existing financial year')
      end

      it 'rejects when existing period encompasses new period' do
        new_fy = FactoryBot.build(:financial_year,
                                 company_id: company.id,
                                 start_date: DateTime.parse("01-03-2024"),
                                 end_date: DateTime.parse("30-09-2024").end_of_day)
        expect(new_fy).to be_invalid
        expect(new_fy.errors[:base]).to include('dates overlap with existing financial year')
      end

      it 'allows updating existing financial year without triggering overlap' do
        existing_fy.end_date = DateTime.parse("30-11-2024").end_of_day
        expect(existing_fy).to be_valid
      end
    end

    describe "#start_date_is_first_day_of_month" do
      let(:financial_year) { FactoryBot.build(:financial_year, start_date:, end_date:) }
      let(:start_date) { DateTime.parse("01-01-2021") }
      let(:end_date) { DateTime.parse("31-12-2022").end_of_day }

      context "when start_date is not the first day of a month" do
        let(:start_date) { DateTime.parse("01-01-2021").end_of_day }

        it "is not valid" do
          expect(financial_year).not_to be_valid
          expect(financial_year.errors[:start_date]).to include("start_date must be the first day of a month")
        end
      end

      context "when start_date is the first day of the month" do
        it "is valid" do
          expect(financial_year).to be_valid
        end
      end
    end

    describe "#end_date_is_last_day_of_month" do
      let(:financial_year) { FactoryBot.build(:financial_year, start_date:, end_date:) }
      let(:start_date) { DateTime.parse("01-01-2021") }
      let(:end_date) { DateTime.parse("31-12-2022").end_of_day }

      context "when end_date is not the last day of a month" do
        let(:end_date) { DateTime.parse("31-12-2022").beginning_of_day }

        it "is not valid" do
          expect(financial_year).not_to be_valid
          expect(financial_year.errors[:end_date]).to include("end_date must be the last day of a month")
        end
      end

      context "when end_date is the last day of the month" do
        it "is valid" do
          expect(financial_year).to be_valid
        end
      end
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations
