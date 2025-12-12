require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Organization::Discount, type: :model do
  subject { FactoryBot.build(:discount, project_version: project_version) }

  let(:company) { FactoryBot.create(:company, :with_bank_detail) }
  let(:client) { FactoryBot.create(:client, company:) }
  let(:project) { FactoryBot.create(:quote, client: client, company: company, bank_detail: company.bank_details.last) }
  let(:project_version) { FactoryBot.create(:project_version, project: project) }

  describe "associations" do
    it { is_expected.to belong_to(:project_version) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:kind).backed_by_column_of_type(:enum).with_values(percentage: "percentage", fixed_amount: "fixed_amount") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:kind) }
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_presence_of(:position) }
    it { is_expected.to validate_presence_of(:original_discount_uuid) }

    describe "value numericality" do
      it { is_expected.to validate_numericality_of(:value).is_greater_than(0) }

      context "when kind is percentage" do
        subject(:percentage_discount) { FactoryBot.build(:discount, :percentage, project_version: project_version) }

        it { is_expected.to validate_numericality_of(:value).is_less_than_or_equal_to(1) }

        it "is invalid when value is greater than 1", :aggregate_failures do
          percentage_discount.value = 1.5
          expect(percentage_discount).not_to be_valid
          expect(percentage_discount.errors[:value]).to include("must be less than or equal to 1")
        end

        it "is valid when value is 1" do
          percentage_discount.value = 1
          expect(percentage_discount).to be_valid
        end

        it "is valid when value is 0.5" do
          percentage_discount.value = 0.5
          expect(percentage_discount).to be_valid
        end
      end

      context "when kind is fixed_amount" do
        subject(:fixed_amount_discount) { FactoryBot.build(:discount, :fixed_amount, project_version: project_version) }

        it "allows value greater than 1" do
          fixed_amount_discount.value = 500
          expect(fixed_amount_discount).to be_valid
        end
      end
    end

    describe "amount numericality" do
      it { is_expected.to validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }

      it "is valid when amount is 0" do
        discount = FactoryBot.build(:discount, project_version: project_version, amount: 0)
        expect(discount).to be_valid
      end

      it "is invalid when amount is negative", :aggregate_failures do
        discount = FactoryBot.build(:discount, project_version: project_version, amount: -10)
        expect(discount).not_to be_valid
        expect(discount.errors[:amount]).to include("must be greater than or equal to 0")
      end
    end

    describe "position uniqueness" do
      before { FactoryBot.create(:discount, project_version: project_version, position: 1) }

      it { is_expected.to validate_uniqueness_of(:position).scoped_to(:project_version_id) }

      it "is invalid when position is duplicated in same project_version", :aggregate_failures do
        duplicate_discount = FactoryBot.build(:discount, project_version: project_version, position: 1)
        expect(duplicate_discount).not_to be_valid
        expect(duplicate_discount.errors[:position]).to include("has already been taken")
      end

      it "is valid when position is unique in same project_version" do
        unique_discount = FactoryBot.build(:discount, project_version: project_version, position: 2)
        expect(unique_discount).to be_valid
      end

      it "is valid when position is duplicated in different project_version" do
        other_project_version = FactoryBot.create(:project_version, project: project)
        other_discount = FactoryBot.build(:discount, project_version: other_project_version, position: 1)
        expect(other_discount).to be_valid
      end
    end
  end

  describe "scopes" do
    describe ".ordered" do
      let!(:third_discount) { FactoryBot.create(:discount, project_version: project_version, position: 3) }
      let!(:first_discount) { FactoryBot.create(:discount, project_version: project_version, position: 1) }
      let!(:second_discount) { FactoryBot.create(:discount, project_version: project_version, position: 2) }

      it "returns discounts ordered by position" do
        expect(described_class.ordered).to eq([ first_discount, second_discount, third_discount ])
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
