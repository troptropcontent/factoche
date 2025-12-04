# frozen_string_literal: true

require "rails_helper"
require "support/shared_contexts/organization/projects/a_company_with_some_quotes"

# rubocop:disable RSpec/MultipleExpectations, RSpec/IndexedLet
RSpec.describe Organization::Discounts::Duplicate do
  include_context "a company with some quotes", number_of_quotes: 1

  describe ".call" do
    let(:original_version) { first_quote_version }
    let!(:new_version) { FactoryBot.create(:project_version, project: first_quote, number: 2) }

    context "with no discounts" do
      it "returns the new project version" do
        result = described_class.call(
          original_project_version: original_version,
          new_project_version: new_version
        )

        expect(result.success?).to be true
        expect(result.data).to eq(new_version)
        expect(new_version.discounts.count).to eq(0)
      end
    end

    context "with a single discount" do
      let!(:original_discount) do
        FactoryBot.create(:discount,
          project_version: original_version,
          kind: "fixed_amount",
          value: 100,
          amount: 100,
          position: 1,
          name: "Early bird discount"
        )
      end

      it "duplicates the discount and carry forward only relevant attributes" do
        result = described_class.call(
          original_project_version: original_version,
          new_project_version: new_version
        )

        expect(result.success?).to be true
        expect(result.data).to eq(new_version)
        expect(new_version.discounts.count).to eq(1)

        new_discount = new_version.discounts.first
        expect(new_discount.kind).to eq("fixed_amount")
        expect(new_discount.value).to eq(100)
        expect(new_discount.amount).to eq(100)
        expect(new_discount.position).to eq(1)
        expect(new_discount.name).to eq("Early bird discount")
        expect(new_discount.original_discount_uuid).not_to eq(original_discount.original_discount_uuid)
      end

      it "creates a new discount record with different id" do
        result = described_class.call(
          original_project_version: original_version,
          new_project_version: new_version
        )

        new_discount = new_version.discounts.first
        expect(new_discount.id).not_to eq(original_discount.id)
        expect(new_discount.project_version_id).to eq(new_version.id)
      end
    end

    context "with multiple discounts" do
      let!(:discount1) do
        FactoryBot.create(:discount,
          project_version: original_version,
          kind: "fixed_amount",
          value: 50,
          amount: 50,
          position: 1,
          name: "Discount 1"
        )
      end

      let!(:discount2) do
        FactoryBot.create(:discount,
          project_version: original_version,
          kind: "percentage",
          value: 0.10,
          amount: 995,
          position: 2,
          name: "Discount 2"
        )
      end

      let!(:discount3) do
        FactoryBot.create(:discount,
          project_version: original_version,
          kind: "fixed_amount",
          value: 25,
          amount: 25,
          position: 3
        )
      end

      it "duplicates all discounts in order" do
        result = described_class.call(
          original_project_version: original_version,
          new_project_version: new_version
        )

        expect(result.success?).to be true
        expect(result.data).to eq(new_version)
        expect(new_version.discounts.count).to eq(3)

        new_discounts = new_version.discounts.order(:position)

        # First discount
        expect(new_discounts[0].kind).to eq("fixed_amount")
        expect(new_discounts[0].value).to eq(50)
        expect(new_discounts[0].position).to eq(1)
        expect(new_discounts[0].name).to eq("Discount 1")

        # Second discount
        expect(new_discounts[1].kind).to eq("percentage")
        expect(new_discounts[1].value).to eq(0.10)
        expect(new_discounts[1].position).to eq(2)
        expect(new_discounts[1].name).to eq("Discount 2")

        # Third discount
        expect(new_discounts[2].kind).to eq("fixed_amount")
        expect(new_discounts[2].value).to eq(25)
        expect(new_discounts[2].position).to eq(3)
        expect(new_discounts[2].name).to eq("Earlybird discount")
      end

      it "does not preserves original_discount_uuid" do
        described_class.call(
          original_project_version: original_version,
          new_project_version: new_version
        )

        new_discounts = new_version.discounts.order(:position)

        expect(new_discounts[0].original_discount_uuid).not_to eq(discount1.original_discount_uuid)
        expect(new_discounts[1].original_discount_uuid).not_to eq(discount2.original_discount_uuid)
        expect(new_discounts[2].original_discount_uuid).not_to eq(discount3.original_discount_uuid)
      end
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations, RSpec/IndexedLet
