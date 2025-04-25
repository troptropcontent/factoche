require "rails_helper"
require 'support/shared_contexts/organization/projects/a_company_with_an_order'
RSpec.describe Accounting::CreditNote, type: :model do
  include_context 'a company with an order'

  describe "validations" do
    subject(:credit_note) { Accounting::Invoices::Cancel.call(invoice.id).data[:credit_note] }

    let(:invoice) {
      proforma = Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data
      Accounting::Proformas::Post.call(proforma.id).data
    }

    it { is_expected.to define_enum_for(:status).backed_by_column_of_type(:enum).with_values(posted: "posted").with_default(:posted) }
    it { is_expected.to belong_to(:invoice).class_name("Accounting::Invoice").with_foreign_key(:holder_id) }

    describe "#valid_number" do
      context "with valid format" do
        it "is valid" do
          credit_note.number = "CN-2024-001"

          expect(credit_note).to be_valid
        end
      end

      context "with invalid format" do
        it "is invalid", :aggregate_failures do
          credit_note.number = "INVALID-001"
          expect(credit_note).not_to be_valid
          expect(credit_note.errors[:number]).to include("must match format CN-YEAR-SEQUENCE")
        end

        it "is invalid without year", :aggregate_failures do
          credit_note.number = "CN-001"
          expect(credit_note).not_to be_valid
          expect(credit_note.errors[:number]).to include("must match format CN-YEAR-SEQUENCE")
        end

        it "is invalid without sequence", :aggregate_failures do
          credit_note.number = "CN-2024"
          expect(credit_note).not_to be_valid
          expect(credit_note.errors[:number]).to include("must match format CN-YEAR-SEQUENCE")
        end
      end
    end
  end

  describe "constants" do
    it "uses Invoice::Context for CONTEXT" do
      expect(described_class::CONTEXT).to eq(Accounting::Invoice::Context)
    end

    it "defines NUMBER_PREFIX as CN" do
      expect(described_class::NUMBER_PREFIX).to eq("CN")
    end
  end
end
