require "rails_helper"

RSpec.describe Accounting::Invoice, type: :model do
  describe "validations" do
    subject(:invoice) { FactoryBot.build(:invoice) }

    it { is_expected.to define_enum_for(:status).backed_by_column_of_type(:enum).with_values(draft: "draft", voided: "voided", posted: "posted", cancelled: "cancelled").with_default(:draft) }

    describe "#valid_number" do
      context "with unpublished status" do
        it "validates number format for draft status", :aggregate_failures do
          invoice.status = "draft"
          invoice.number = "PRO-2024-001"
          expect(invoice).to be_valid

          invoice.number = "INV-001"
          expect(invoice).not_to be_valid
          expect(invoice.errors[:number]).to include("must match format PRO-YEAR-SEQUENCE")
        end

        it "validates number format for voided status" do
          invoice.status = "voided"
          invoice.number = "PRO-2024-001"
          expect(invoice).to be_valid
        end
      end

      context "with published status" do
        it "validates number format for posted status", :aggregate_failures do
          invoice.status = "posted"
          invoice.number = "INV-2024-001"
          expect(invoice).to be_valid

          invoice.number = "PRO-001"
          expect(invoice).not_to be_valid
          expect(invoice.errors[:number]).to include("must match format INV-YEAR-SEQUENCE")
        end

        it "validates number format for cancelled status" do
          invoice.status = "cancelled"
          invoice.number = "INV-2024-001"
          expect(invoice).to be_valid
        end
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
          invoice.number = "PRO-2024-00001"
          invoice.context = context
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
          invoice.number = "PRO-2024-00001"
          invoice.context = context
        }

        it { is_expected.not_to be_valid }
      end
    end
  end

  describe "scopes" do
    let!(:draft_invoice) { FactoryBot.create(:invoice, company_id: 1, holder_id: 1, number: "PRO-2024-00001") }
    let!(:voided_invoice) { FactoryBot.create(:invoice, :voided, company_id: 1, holder_id: 1, number: "PRO-2024-00002") }
    let!(:posted_invoice) { FactoryBot.create(:invoice, :posted, company_id: 1, holder_id: 1, number: "INV-2024-00001") }
    let!(:cancelled_invoice) { FactoryBot.create(:invoice, :cancelled, company_id: 1, holder_id: 1, number: "INV-2024-00002") }

    describe ".published" do
      it "returns only posted and cancelled invoices" do
        published_invoices = described_class.published
        expect(published_invoices).to contain_exactly(posted_invoice, cancelled_invoice)
      end
    end

    describe ".unpublished" do
      it "returns only draft and voided invoices" do
        unpublished_invoices = described_class.unpublished
        expect(unpublished_invoices).to contain_exactly(draft_invoice, voided_invoice)
      end
    end
  end
end
