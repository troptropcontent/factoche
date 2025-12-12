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
        "project_total_amount" => "400", # 200 + 100 + 100 (net amount for display)
        "project_total_amount_before_discounts" => "400", # Same as total when no discounts
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

      context "when project has discounts but none applied to invoice" do
        let(:invoice_context) do
          super().merge({
            "project_total_amount" => "350", # NET project total: 400 (items) - 50 (discounts)
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

        it 'returns only charge lines (no automatic discount calculation)', :aggregate_failures do
          expect(result.data.length).to eq(2) # 2 charges only, no automatic discounts

          # Check charge lines
          charge_lines = result.data.select { |line| line[:kind] == "charge" }
          expect(charge_lines.length).to eq(2)

          # No discount lines since none applied to this invoice
          discount_lines = result.data.select { |line| line[:kind] == "discount" }
          expect(discount_lines.length).to eq(0)
        end
      end

      context "when discount amounts are provided for this invoice" do
        subject(:result) { described_class.call(invoice_context, new_invoice_items, new_invoice_discounts) }

        let(:invoice_context) do
          super().merge({
            "project_total_amount" => "350", # NET project total: 400 (items) - 50 (discounts)
            "project_version_discounts" => [
              {
                "original_discount_uuid" => "discount-uuid-1",
                "kind" => "fixed_amount",
                "value" => "50",
                "amount" => "50",
                "position" => 1,
                "name" => "Early payment discount",
                "previously_billed_amount" => "0"
              }
            ]
          })
        end

        let(:new_invoice_discounts) do
          [
            { original_discount_uuid: "discount-uuid-1", discount_amount: "20.00" }
          ]
        end

        it 'uses provided discount amounts instead of calculated proportions', :aggregate_failures do
          expect(result.data.length).to eq(3) # 2 charges + 1 discount

          # Check discount line uses provided amount
          discount_lines = result.data.select { |line| line[:kind] == "discount" }
          expect(discount_lines.length).to eq(1)

          discount_line = discount_lines.first
          expect(discount_line).to include(
            holder_id: "discount-uuid-1",
            quantity: 1,
            unit: "€",
            unit_price_amount: BigDecimal("-20.00"),
            excl_tax_amount: BigDecimal("-20.00"),
            tax_rate: 0,
            group_id: nil,
            kind: "discount"
          )
        end

        context "when discount amount is zero" do
          let(:new_invoice_discounts) do
            [
              { original_discount_uuid: "discount-uuid-1", discount_amount: "0" }
            ]
          end

          it 'does not create discount line (0€ discount makes no sense)', :aggregate_failures do
            # Should only have charge lines, no discount line for 0€
            expect(result.data.length).to eq(2) # 2 charges only

            discount_lines = result.data.select { |line| line[:kind] == "discount" }
            expect(discount_lines.length).to eq(0)
          end
        end

        context "when multiple discounts are applied" do
          let(:invoice_context) do
            super().merge({
              "project_total_amount" => "300", # 400 - 100
              "project_version_discounts" => [
                {
                  "original_discount_uuid" => "discount-uuid-1",
                  "kind" => "percentage",
                  "value" => "0.1",
                  "amount" => "50",
                  "position" => 1,
                  "name" => "Volume discount",
                  "previously_billed_amount" => "0"
                },
                {
                  "original_discount_uuid" => "discount-uuid-2",
                  "kind" => "fixed_amount",
                  "value" => "50",
                  "amount" => "50",
                  "position" => 2,
                  "name" => "Early payment discount",
                  "previously_billed_amount" => "0"
                }
              ]
            })
          end

          let(:new_invoice_discounts) do
            [
              { original_discount_uuid: "discount-uuid-1", discount_amount: "15.50" },
              { original_discount_uuid: "discount-uuid-2", discount_amount: "25.00" }
            ]
          end

          it 'applies provided amounts to each discount', :aggregate_failures do
            discount_lines = result.data.select { |line| line[:kind] == "discount" }
            expect(discount_lines.length).to eq(2)

            discount_1 = discount_lines.find { |line| line[:holder_id] == "discount-uuid-1" }
            discount_2 = discount_lines.find { |line| line[:holder_id] == "discount-uuid-2" }

            expect(discount_1[:unit_price_amount]).to eq(BigDecimal("-15.50"))
            expect(discount_1[:unit]).to eq("%")

            expect(discount_2[:unit_price_amount]).to eq(BigDecimal("-25.00"))
            expect(discount_2[:unit]).to eq("€")
          end
        end

        context "when only some discounts are applied to invoice" do
          let(:invoice_context) do
            super().merge({
              "project_total_amount" => "300",
              "project_version_discounts" => [
                {
                  "original_discount_uuid" => "discount-uuid-1",
                  "kind" => "fixed_amount",
                  "value" => "50",
                  "amount" => "50",
                  "position" => 1,
                  "name" => "Discount 1",
                  "previously_billed_amount" => "0"
                },
                {
                  "original_discount_uuid" => "discount-uuid-2",
                  "kind" => "fixed_amount",
                  "value" => "50",
                  "amount" => "50",
                  "position" => 2,
                  "name" => "Discount 2",
                  "previously_billed_amount" => "0"
                }
              ]
            })
          end

          let(:new_invoice_discounts) do
            [
              { original_discount_uuid: "discount-uuid-1", discount_amount: "30.00" }
              # discount-uuid-2 not provided for this invoice (no automatic calculation)
            ]
          end

          it 'only applies discounts provided for this invoice (no automatic calculation)', :aggregate_failures do
            discount_lines = result.data.select { |line| line[:kind] == "discount" }
            expect(discount_lines.length).to eq(1) # Only discount-1

            discount_1 = discount_lines.find { |line| line[:holder_id] == "discount-uuid-1" }

            # Provided amount used
            expect(discount_1[:unit_price_amount]).to eq(BigDecimal("-30.00"))

            # discount-uuid-2 NOT applied since no amount provided for this invoice
            discount_2 = discount_lines.find { |line| line[:holder_id] == "discount-uuid-2" }
            expect(discount_2).to be_nil
          end
        end
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
