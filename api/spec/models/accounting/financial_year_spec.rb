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
                                         start_date: Date.new(2024, 1, 1),
                                         end_date: Date.new(2024, 12, 31))
        expect(financial_year).to be_valid
      end

      it 'is invalid when end_date equals start_date' do
        financial_year = FactoryBot.build(:financial_year,
                                         start_date: Date.new(2024, 1, 1),
                                         end_date: Date.new(2024, 1, 1))
        expect(financial_year).to be_invalid
        expect(financial_year.errors[:end_date]).to include('must be after start date')
      end

      it 'is invalid when end_date is before start_date' do
        financial_year = FactoryBot.build(:financial_year,
                                         start_date: Date.new(2024, 12, 31),
                                         end_date: Date.new(2024, 1, 1))
        expect(financial_year).to be_invalid
        expect(financial_year.errors[:end_date]).to include('must be after start date')
      end
    end

    describe '#no_overlapping_exercises' do
      let(:company) { FactoryBot.create(:company) }
      let!(:existing_fy) { FactoryBot.create(:financial_year,
                                            company_id: company.id,
                                            start_date: Date.new(2024, 1, 1),
                                            end_date: Date.new(2024, 12, 31)) }

      it 'allows non-overlapping financial years for same company' do
        new_fy = FactoryBot.build(:financial_year,
                                 company_id: company.id,
                                 start_date: Date.new(2025, 1, 1),
                                 end_date: Date.new(2025, 12, 31))
        expect(new_fy).to be_valid
      end

      it 'allows same dates for different companies' do
        other_company = FactoryBot.create(:company)
        new_fy = FactoryBot.build(:financial_year,
                                 company_id: other_company.id,
                                 start_date: Date.new(2024, 1, 1),
                                 end_date: Date.new(2024, 12, 31))
        expect(new_fy).to be_valid
      end

      it 'rejects when new period starts during existing period' do
        new_fy = FactoryBot.build(:financial_year,
                                 company_id: company.id,
                                 start_date: Date.new(2024, 6, 1),
                                 end_date: Date.new(2025, 5, 31))
        expect(new_fy).to be_invalid
        expect(new_fy.errors[:base]).to include('dates overlap with existing financial year')
      end

      it 'rejects when new period ends during existing period' do
        new_fy = FactoryBot.build(:financial_year,
                                 company_id: company.id,
                                 start_date: Date.new(2023, 6, 1),
                                 end_date: Date.new(2024, 5, 31))
        expect(new_fy).to be_invalid
        expect(new_fy.errors[:base]).to include('dates overlap with existing financial year')
      end

      it 'rejects when new period encompasses existing period' do
        new_fy = FactoryBot.build(:financial_year,
                                 company_id: company.id,
                                 start_date: Date.new(2023, 1, 1),
                                 end_date: Date.new(2025, 12, 31))
        expect(new_fy).to be_invalid
        expect(new_fy.errors[:base]).to include('dates overlap with existing financial year')
      end

      it 'rejects when existing period encompasses new period' do
        new_fy = FactoryBot.build(:financial_year,
                                 company_id: company.id,
                                 start_date: Date.new(2024, 3, 1),
                                 end_date: Date.new(2024, 9, 30))
        expect(new_fy).to be_invalid
        expect(new_fy.errors[:base]).to include('dates overlap with existing financial year')
      end

      it 'allows updating existing financial year without triggering overlap' do
        existing_fy.end_date = Date.new(2024, 11, 30)
        expect(existing_fy).to be_valid
      end
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations
