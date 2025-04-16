require "rails_helper"

RSpec.describe Accounting::Proforma, type: :model do
  describe "validations" do
    subject(:proforma) { FactoryBot.build(:proforma) }

    it { is_expected.to define_enum_for(:status).backed_by_column_of_type(:enum).with_values(draft: "draft", voided: "voided").with_default(:draft) }

    describe "#valid_number" do
      it "validates number respect the expected format", :aggregate_failures do
        proforma.status = "draft"
        proforma.number = "PRO-2024-001"
        expect(proforma).to be_valid

        proforma.number = "INV-001"
        expect(proforma).not_to be_valid
        expect(proforma.errors[:number]).to include("must match format PRO-YEAR-SEQUENCE")
      end
    end

    describe "context" do
      context "when the context is valid" do
        let(:context) do
          {
            project_name: "toto",
            project_version_retention_guarantee_rate: 0.1,
            project_version_number: 1,
            project_version_date: Time.current.iso8601,
            project_total_amount: 1000.0,
            project_total_previously_billed_amount: 500.0,
            project_version_items: [ {
              original_item_uuid: "123e4567-e89b-12d3-a456-426614174000",
              group_id: 1,
              name: "Item 1",
              description: "Description",
              quantity: 2,
              unit: "pieces",
              unit_price_amount: 100.0,
              tax_rate: 0.2,
              previously_billed_amount: 0.0
            } ],
            project_version_item_groups: [ {
              id: 1,
              name: "Group 1",
              description: "Group Description"
            } ]
          }
        end

        before {
          proforma.number = "PRO-2024-00001"
          proforma.context = context
        }

        it { is_expected.to be_valid }
      end

      context "when the context is not valid" do
        let(:context) do
          {
            project_version_retention_guarantee_rate: 0.1
          }
        end

        before {
          proforma.number = "PRO-2024-00001"
          proforma.context = context
        }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
