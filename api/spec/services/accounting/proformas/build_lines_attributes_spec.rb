require 'rails_helper'

RSpec.describe Accounting::Proformas::BuildLinesAttributes do
  describe '.call' do
    subject(:result) { described_class.call(invoice_context, new_invoice_items) }

    let(:invoice_context) do
      {
        "project_version_items" => [
          {
            "original_item_uuid" => "item-123",
            "unit" => "hours",
            "unit_price_amount" => "100",
            "quantity" => 2,
            "tax_rate" => "0.20",
            "group_id" => "group-1"
          },
          {
            "original_item_uuid" => "item-456",
            "unit" => "pieces",
            "unit_price_amount" => "50",
            "quantity" => 2,
            "tax_rate" => "0.20",
            "group_id" => "group-2"
          },
          {
            "original_item_uuid" => "item-789",
            "unit" => "pieces",
            "unit_price_amount" => "50",
            "quantity" => 2,
            "tax_rate" => "0.20",
            "group_id" => "group-2"
          }
        ],
        "project_version_discounts" => [],
        "project_total_amount" => "400", # 200 + 100 + 100
        "project_version_retention_guarantee_rate" => "0.05"
      }
    end

    let(:new_invoice_items) do
      [
        { original_item_uuid: "item-123", invoice_amount: "150" },
        { original_item_uuid: "item-456", invoice_amount: "75" }
      ]
    end

    context 'when successful' do
      it { is_expected.to be_success }

      # rubocop:disable RSpec/ExampleLength
      it 'returns a success result with correct attributes', :aggregate_failures do
        expect(result.data).to be_an(Array)
        expect(result.data.length).to eq(2) # Only create attributes for provided invoice amounts, not all items from context to avoid useless lines

        first_line = result.data.first
        expect(first_line).to include(
          holder_id: "item-123",
          quantity: BigDecimal("1.5"), # 150/100
          unit: "hours",
          unit_price_amount: BigDecimal("100"),
          excl_tax_amount: BigDecimal("150"),
          tax_rate: BigDecimal("0.20"),
          group_id: "group-1",
          kind: "charge"
        )

        second_line = result.data.last
        expect(second_line).to include(
          holder_id: "item-456",
          quantity: BigDecimal("1.5"), # 75/50
          unit: "pieces",
          unit_price_amount: BigDecimal("50"),
          excl_tax_amount: BigDecimal("75"),
          tax_rate: BigDecimal("0.20"),
          group_id: "group-2",
          kind: "charge"
        )
      end
      # rubocop:enable RSpec/ExampleLength

      context "with zero invoice amounts" do
        let(:new_invoice_items) do
          [
            { original_item_uuid: "item-123", invoice_amount: "0" }
          ]
        end

        it 'return lines with no amount and quantity', :aggregate_failures do
          first_line = result.data.first
          expect(first_line[:quantity]).to eq(BigDecimal("0"))
          expect(first_line[:excl_tax_amount]).to eq(BigDecimal("0"))
        end
      end

      context "when no invoice items are provided" do
        let(:new_invoice_items) { [] }

        it 'return empty invoice lines for each items', :aggregate_failures do
          expect(result.data.all? { |line| line[:quantity] == BigDecimal("0") }).to be true
          expect(result.data.all? { |line| line[:excl_tax_amount] == BigDecimal("0") }).to be true
        end
      end

      context "when project has discounts" do
        let(:invoice_context) do
          super().merge({
            "project_version_discounts" => [
              {
                "original_discount_uuid" => "discount-uuid-1",
                "kind" => "fixed_amount",
                "value" => "50",
                "amount" => "50",
                "position" => 1,
                "name" => "Early payment discount"
              }
            ]
          })
        end

        # rubocop:disable RSpec/ExampleLength
        it 'returns charge lines and discount lines', :aggregate_failures do
          # Project total: 400€
          # Invoice total: 150 + 75 = 225€
          # Invoice proportion: 225/400 = 0.5625
          # Prorated discount: 50 * 0.5625 = 28.13€ (rounded to 28.12€)

          expect(result.data.length).to eq(3) # 2 charges + 1 discount

          # Check charge lines
          charge_lines = result.data.select { |line| line[:kind] == "charge" }
          expect(charge_lines.length).to eq(2)

          # Check discount line
          discount_lines = result.data.select { |line| line[:kind] == "discount" }
          expect(discount_lines.length).to eq(1)

          discount_line = discount_lines.first
          expect(discount_line).to include(
            holder_id: "discount-uuid-1",
            quantity: 1,
            unit: "€",
            tax_rate: 0,
            group_id: nil,
            kind: "discount"
          )

          # Discount should be negative
          expect(discount_line[:unit_price_amount]).to be < 0
          expect(discount_line[:excl_tax_amount]).to be < 0
          expect(discount_line[:unit_price_amount].abs).to be_within(0.01).of(28.12)
        end
        # rubocop:enable RSpec/ExampleLength
      end
    end

    context 'when failing' do
      context "when the context is not valid" do
        let(:invoice_context) do
          {
            "invalid_context" => []
          }
        end

        it { is_expected.to be_failure }

        it 'returns a failure result when required keys are missing', :aggregate_failures do
          expect(result.error).to be_a(KeyError)
          expect(result.error.message).to include("key not found")
          expect(result.error.message).to include("project_version_items")
        end
      end

      context "when an invoice_item would result in an over invoiced is not valid" do
        let(:new_invoice_items) do
          [
            { original_item_uuid: "item-123", invoice_amount: "10000" }
          ]
        end

        it { is_expected.to be_failure }

        it 'returns a failure result with over-invoicing error', :aggregate_failures do
          expect(result.error).to be_a(StandardError)
          expect(result.error.message).to include("Total invoiced amount (10000.0) would exceed the maximum allowed amount (200.0) for item item-123")
        end
      end
    end
  end
end
