require 'rails_helper'
require "support/shared_contexts/organization/a_company_with_a_project_with_three_item_groups"

module Organization
  RSpec.describe BuildCompletionSnapshotTransactionPayload do
    include_context 'a company with a project with three item groups'

    describe ".call" do
      subject(:result) { described_class.call(completion_snapshot) }

      let(:project_version_first_item_group_item_quantity) { 1 }
      let(:project_version_first_item_group_item_unit_price_cents) { 1000 }
      let(:project_version_first_item_group_item_name) { "First Item Name" }
      let(:project_version_first_item_group_item_unit) { "First Item Unit" }
      let(:project_version_second_item_group_item_quantity) { 2 }
      let(:project_version_second_item_group_item_unit_price_cents) { 2000 }
      let(:project_version_second_item_group_item_name) { "Second Item Name" }
      let(:project_version_third_item_group_item_quantity) { 3 }
      let(:project_version_third_item_group_item_unit_price_cents) { 3000 }
      let(:project_version_third_item_group_item_name) { "Third Item Name" }

      let(:completion_snapshot) do
        FactoryBot.create(
          :completion_snapshot,
          project_version: project_version,
          completion_snapshot_items_attributes: [
            {
              item_id: project_version_first_item_group_item.id,
              completion_percentage: BigDecimal("0.05")
            },
            {
              item_id: project_version_second_item_group_item.id,
              completion_percentage: BigDecimal("0.10")
            },
            {
              item_id: project_version_third_item_group_item.id,
              completion_percentage: BigDecimal("0.15")
            }
          ]
        )
      end

      describe "items" do
        context "when there are no previous invoices for any items" do
          let(:expected_attributes) { { id: project_version_first_item_group_item.id,
          original_item_uuid: project_version_first_item_group_item.original_item_uuid,
          name: "First Item Name",
          quantity: 1,
          unit: "First Item Unit",
          unit_price_amount: BigDecimal("10"),
          previously_invoiced_amount: BigDecimal("0"),
          new_completion_percentage_rate: BigDecimal("0.05") }}

          it "returns all items with zero previously invoiced amounts", :aggregate_failures do
            expect(result.items.length).to eq(3)
            expect(result.items.first).to have_attributes(**expected_attributes)
          end
        end

        context "when there is some previous invoice for some items" do
          before do
            previous_snapshot = FactoryBot.create(
              :completion_snapshot,
              project_version: project_version
            )
            payload = {
              transaction: {
                items: [
                  {
                    original_item_uuid: project_version_first_item_group_item.original_item_uuid,
                    amount: "0.2"
                  },
                  {
                    original_item_uuid: project_version_second_item_group_item.original_item_uuid,
                    amount: "0.4"
                  }
                ]
              }
            }
            invoice = FactoryBot.create(:invoice, payload: payload)
            previous_snapshot.update(invoice: invoice)
          end

          let(:expected_attributes) { {
            id: project_version_first_item_group_item.id,
            original_item_uuid: project_version_first_item_group_item.original_item_uuid,
            name: "First Item Name",
            quantity: 1,
            unit: "First Item Unit",
            unit_price_amount: BigDecimal("10"),
            previously_invoiced_amount: BigDecimal("0.2"),
            new_completion_percentage_rate: BigDecimal("0.05") }}

          it "includes previously invoiced amounts in the item payloads", :aggregate_failures do
            expect(result.items.length).to eq(3)
            expect(result.items.first).to have_attributes(**expected_attributes)
          end
        end
      end

      describe "item_groups" do
        it "returns item groups with their name, description and position", :aggregate_failures do
          expect(result.item_groups.length).to eq(3)
          expect(result.item_groups.first).to have_attributes(
            name: "Item Group 1",
            id: project_version_first_item_group.id,
            description: nil,
            position: 1
          )
        end
      end

      describe "total_excl_tax_amount" do
        context "when there is no previous invoices" do
          it "returns item groups with their name, description and position", :aggregate_failures do
            # First item: 1 * 10 € * (5 % - 0 %) = 0.50 €
            # Second item: 2 * 20 € * (10 % - 0 %) = 4.00 €
            # Third item: 3 * 30 € * (15 % - 0 %) = 13.50 €
            # Total: 0.50 € + 4.00 € + 13.50 € = 18.00 €
            expect(result.total_excl_tax_amount).to eq(BigDecimal("18"))
          end
        end

        context "when there is previous invoices" do
          before do
            previous_snapshot = FactoryBot.create(
              :completion_snapshot,
              project_version: project_version
            )
            payload = {
              transaction: {
                items: [
                  {
                    original_item_uuid: project_version_first_item_group_item.original_item_uuid,
                    amount: "0.2"
                  },
                  {
                    original_item_uuid: project_version_second_item_group_item.original_item_uuid,
                    amount: "0.4"
                  }
                ]
              }
            }
            invoice = FactoryBot.create(:invoice, payload: payload)
            previous_snapshot.update(invoice: invoice)
          end

          it "returns item groups with their name, description and position", :aggregate_failures do
            # First item (1 previous invoice): 1 * 10 € * 5 % - 0.2 € = 0.3 €
            # Second item (1 previous invoice): 2 * 20 € * 10 % - 0.4 € = 3.6 €
            # Third item (no previous invoice): 3 * 30 € * 15 % = 13.5 €
            # Total: 0.3 € + 3.6 € + 13.5 € = 17.4 €
            expect(result.total_excl_tax_amount).to eq(BigDecimal("17.4"))
          end
        end
      end

      describe "tax_rate & tax_amount" do
        context "when there is no tax rate define in the company's settings" do
          before { company.config.update!(settings: {}) }

          it "takes the default tax rate", :aggregate_failures do
            # 20 % * 18 € = 3.6 €
            expect(result.tax_rate).to eq(BigDecimal("0.20"))
            expect(result.tax_amount).to eq(BigDecimal("3.6"))
          end
        end

        context "when there is a custom tax rate define in the company's settings" do
          before { company.config.update!(settings: { "vat_rate"=>"0.10" }) }

          it "takes the default tax rate", :aggregate_failures do
            # 10 % * 18 € = 1.8 €
            expect(result.tax_rate).to eq(BigDecimal("0.10"))
            expect(result.tax_amount).to eq(BigDecimal("1.8"))
          end
        end
      end

      describe "retention_guarantee_amount & retention_guarantee_rate" do
        let(:project_version_retention_guarantee_rate) { 500 }

        it "takes the project_version rate", :aggregate_failures do
          # Base amount (total_excl_tax_amount + tax_amount): 18 € + 3.6 € = 21.6 €
          # Calculation: 21.6 * 0.05 = 1.08 €
          expect(result.retention_guarantee_rate).to eq(BigDecimal("0.05"))
          expect(result.retention_guarantee_amount).to eq(BigDecimal("1.08"))
        end
      end
    end
  end
end
