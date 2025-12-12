# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Organization::ProjectVersions::ComputeProjectVersionTotals do
  subject(:result) { described_class.call(project_version) }

  let(:company) { FactoryBot.create(:company, :with_bank_detail) }
  let(:client) { FactoryBot.create(:client, company: company) }
  let(:project) { FactoryBot.create(:quote, client: client, company: company, bank_detail: company.bank_details.last) }
  let(:project_version) { FactoryBot.create(:project_version, project: project) }

  describe ".call" do
    context "with empty items list" do
      it "returns zero totals", :aggregate_failures do
        expect(result).to be_success
        expect(result.data).to eq({
          subtotal: 0.to_d,
          total_discount: 0.to_d,
          total_tax: 0.to_d,
          total_incl_tax: 0.to_d
        })
      end
    end

    context "with items but no discounts" do
      before do
        FactoryBot.create(
          :item,
          project_version: project_version,
          quantity: 10,
          unit_price_amount: 100.0,
          tax_rate: 0.20
        )
        FactoryBot.create(
          :item,
          project_version: project_version,
          quantity: 5,
          unit_price_amount: 50.0,
          tax_rate: 0.10
        )
      end

      it "calculates totals correctly", :aggregate_failures do
        expect(result).to be_success

        # Subtotal: (10 * 100) + (5 * 50) = 1000 + 250 = 1250
        # No discount
        # Tax: (1000 * 0.20) + (250 * 0.10) = 200 + 25 = 225
        # Total incl tax: 1250 + 225 = 1475
        expect(result.data).to eq({
          subtotal: 1250.to_d,
          total_discount: 0.to_d,
          total_tax: 225.to_d,
          total_incl_tax: 1475.to_d
        })
      end
    end

    context "with items and a single percentage discount" do
      before do
        FactoryBot.create(
          :item,
          project_version: project_version,
          quantity: 10,
          unit_price_amount: 100.0,
          tax_rate: 0.20
        )
        FactoryBot.create(
          :item,
          project_version: project_version,
          quantity: 5,
          unit_price_amount: 50.0,
          tax_rate: 0.10
        )

        # 10% discount on subtotal of 1250 = 125
        FactoryBot.create(
          :discount,
          :percentage,
          project_version: project_version,
          value: 0.10,
          amount: 125.0,
          position: 1
        )
      end

      it "applies discount before tax and distributes proportionally", :aggregate_failures do
        expect(result).to be_success

        # Subtotal: 1250
        # Discount: 125 (10%)
        # After discount: 1125
        # Item 1 proportion: 1000/1250 = 0.8, discount share: 100
        # Item 1 after discount: 900, tax: 180, total: 1080
        # Item 2 proportion: 250/1250 = 0.2, discount share: 25
        # Item 2 after discount: 225, tax: 22.5, total: 247.5
        # Total incl tax: 1327.5
        expect(result.data[:subtotal]).to eq(1250.to_d)
        expect(result.data[:total_discount]).to eq(125.to_d)
        expect(result.data[:total_tax]).to eq(202.5.to_d)
        expect(result.data[:total_incl_tax]).to eq(1327.5.to_d)
      end
    end

    context "with items and a single fixed amount discount" do
      before do
        FactoryBot.create(
          :item,
          project_version: project_version,
          quantity: 10,
          unit_price_amount: 100.0,
          tax_rate: 0.20
        )

        # Fixed discount of 200
        FactoryBot.create(
          :discount,
          :fixed_amount,
          project_version: project_version,
          value: 200.0,
          amount: 200.0,
          position: 1
        )
      end

      it "applies fixed discount before tax", :aggregate_failures do
        expect(result).to be_success

        # Subtotal: 1000
        # Discount: 200
        # After discount: 800
        # Tax: 800 * 0.20 = 160
        # Total incl tax: 960
        expect(result.data[:subtotal]).to eq(1000.to_d)
        expect(result.data[:total_discount]).to eq(200.to_d)
        expect(result.data[:total_tax]).to eq(160.to_d)
        expect(result.data[:total_incl_tax]).to eq(960.to_d)
      end
    end

    context "with multiple discounts applied sequentially" do
      before do
        FactoryBot.create(
          :item,
          project_version: project_version,
          quantity: 10,
          unit_price_amount: 100.0,
          tax_rate: 0.20
        )

        # First discount: 10% of 1000 = 100
        FactoryBot.create(
          :discount,
          :percentage,
          project_version: project_version,
          value: 0.10,
          amount: 100.0,
          position: 1
        )

        # Second discount: 5% of 900 = 45
        FactoryBot.create(
          :discount,
          :percentage,
          project_version: project_version,
          value: 0.05,
          amount: 45.0,
          position: 2
        )
      end

      it "applies discounts sequentially in order of position", :aggregate_failures do
        expect(result).to be_success

        # Subtotal: 1000
        # First discount: 100 (10%), running total: 900
        # Second discount: 45 (5% of 900), running total: 855
        # Total discount: 145
        # Tax: 855 * 0.20 = 171
        # Total incl tax: 1026
        expect(result.data[:subtotal]).to eq(1000.to_d)
        expect(result.data[:total_discount]).to eq(145.to_d)
        expect(result.data[:total_tax]).to eq(171.to_d)
        expect(result.data[:total_incl_tax]).to eq(1026.to_d)
      end
    end

    context "with multiple items with different tax rates and multiple discounts" do
      before do
        FactoryBot.create(
          :item,
          project_version: project_version,
          quantity: 10,
          unit_price_amount: 100.0,
          tax_rate: 0.20
        )
        FactoryBot.create(
          :item,
          project_version: project_version,
          quantity: 5,
          unit_price_amount: 50.0,
          tax_rate: 0.055
        )

        # Total: 1250
        # First discount: 100
        FactoryBot.create(
          :discount,
          :fixed_amount,
          project_version: project_version,
          value: 100.0,
          amount: 100.0,
          position: 1
        )

        # Second discount: 50
        FactoryBot.create(
          :discount,
          :fixed_amount,
          project_version: project_version,
          value: 50.0,
          amount: 50.0,
          position: 2
        )
      end

      it "distributes total discount proportionally and applies different tax rates", :aggregate_failures do
        expect(result).to be_success

        # Subtotal: 1250
        # Total discount: 150 (100 + 50 applied sequentially)
        # Item 1 proportion: 1000/1250 = 0.8, discount share: 120
        # Item 1 after discount: 880, tax: 176, total: 1056
        # Item 2 proportion: 250/1250 = 0.2, discount share: 30
        # Item 2 after discount: 220, tax: 12.1, total: 232.1
        # Total incl tax: 1289.2 (rounding applied per item)
        expect(result.data[:subtotal]).to eq(1250.to_d)
        expect(result.data[:total_discount]).to eq(150.to_d)
        expect(result.data[:total_tax]).to eq(189.2.to_d)
        expect(result.data[:total_incl_tax]).to eq(1289.2.to_d)
      end
    end

    context "when discount exceeds subtotal" do
      before do
        FactoryBot.create(
          :item,
          project_version: project_version,
          quantity: 1,
          unit_price_amount: 100.0,
          tax_rate: 0.20
        )

        # Discount greater than subtotal
        FactoryBot.create(
          :discount,
          :fixed_amount,
          project_version: project_version,
          value: 200.0,
          amount: 200.0,
          position: 1
        )
      end

      it "clamps total to zero", :aggregate_failures do
        expect(result).to be_success

        expect(result.data[:subtotal]).to eq(100.to_d)
        expect(result.data[:total_discount]).to eq(200.to_d)
        expect(result.data[:total_tax]).to eq(0.to_d)
        expect(result.data[:total_incl_tax]).to eq(0.to_d)
      end
    end

    context "when project_version is nil" do
      let(:project_version) { nil }

      it "returns an error", :aggregate_failures do
        expect(result).to be_failure
        expect(result.error).to be_a(Error::UnprocessableEntityError)
        expect(result.error.message).to include("project_version")
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
