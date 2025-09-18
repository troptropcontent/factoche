require "rails_helper"
require 'support/shared_contexts/organization/projects/a_company_with_an_order'
RSpec.describe Accounting::Invoice, type: :model do
  subject(:invoice) {
    proforma = Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data
    Accounting::Proformas::Post.call(proforma.id).data
  }

  let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }

  include_context 'a company with an order'

  describe "validations" do
    it { is_expected.to define_enum_for(:status).backed_by_column_of_type(:enum).with_values(posted: "posted", cancelled: "cancelled").with_default(:posted) }

    describe "#valid_number" do
      it "validates number format", :aggregate_failures do
        expect(invoice).to be_valid

        invoice.number = "INV-001"
        expect(invoice).not_to be_valid
        expect(invoice.errors[:number]).to include("must match format INV-YEAR-MONTH-SEQUENCE")
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
          invoice.context = context
        }

        it { is_expected.not_to be_valid }
      end
    end
  end

  describe "instance method" do
    describe "payment_status" do
      context "when a payment is attached to the invoice" do
        before { Accounting::Payments::Create.call(invoice.id) }

        it "returns paid" do
          expect(invoice.payment_status).to eq('paid')
        end
      end

      context "when a payment is not attached to the invoice" do
        context "when the due_date is past" do
          before { invoice.detail.update(due_date: 2.days.ago) }

          it "returns overdue" do
            expect(invoice.payment_status).to eq('overdue')
          end
        end

        context "when the due_date is not past" do
          it "returns pending" do
            expect(invoice.payment_status).to eq('pending')
          end
        end
      end
    end
  end
end
