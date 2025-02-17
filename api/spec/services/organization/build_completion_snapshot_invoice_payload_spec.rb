require 'rails_helper'
require "support/shared_contexts/organization/a_company_with_a_project_with_three_item_groups"

module Organization
  RSpec.describe BuildCompletionSnapshotInvoicePayload do
    include_context 'a company with a project with three item groups'

    describe ".call" do
      subject(:result) { described_class.call(completion_snapshot) }

      let(:completion_snapshot) do
        FactoryBot.create(
          :completion_snapshot,
          project_version: project_version,
          completion_snapshot_items_attributes: [
            {
              item_id: project_version_first_item_group_item.id,
              completion_percentage: BigDecimal("0.05")
            }
          ]
        )
      end

      before do
        company.update!(
          name: "ACME Corp",
          phone: "+33123456789",
          registration_number: "123456789",
          rcs_city: "Paris",
          rcs_number: "RCS123",
          vat_number: "FR123456789",
          address_city: "Paris",
          address_street: "123 Rue de la Paix",
          address_zipcode: "75001"
        )

        client.update!(
          name: "Client Corp",
          address_city: "Lyon",
          address_street: "456 Avenue Client",
          address_zipcode: "69001"
        )

        company.config.update!(
          settings: {
            "payment_term" => {
              "days" => 30,
              "accepted_methods" => [ "bank_transfer", "check" ]
            },
            "vat_rate" => "0.20"
          }
        )
      end

      # rubocop:disable RSpec/ExampleLength
      it "returns a properly structured invoice payload", :aggregate_failures do
        expect(result).to be_a(described_class::Result)

        # Payment Term
        expect(result.payment_term.days).to eq(30)
        expect(result.payment_term.accepted_methods).to eq([ "bank_transfer", "check" ])

        # Seller
        expect(result.seller.name).to eq("ACME Corp")
        expect(result.seller.phone).to eq("+33123456789")
        expect(result.seller.siret).to eq("123456789")
        expect(result.seller.rcs_city).to eq("Paris")
        expect(result.seller.rcs_number).to eq("RCS123")
        expect(result.seller.vat_number).to eq("FR123456789")
        expect(result.seller.address.city).to eq("Paris")
        expect(result.seller.address.street).to eq("123 Rue de la Paix")
        expect(result.seller.address.zip).to eq("75001")

        # Billing Address
        expect(result.billing_address.name).to eq("Client Corp")
        expect(result.billing_address.address.city).to eq("Lyon")
        expect(result.billing_address.address.street).to eq("456 Avenue Client")
        expect(result.billing_address.address.zip).to eq("69001")

        # Delivery Address (same as billing in this case)
        expect(result.delivery_address.name).to eq("Client Corp")
        expect(result.delivery_address.address.city).to eq("Lyon")
        expect(result.delivery_address.address.street).to eq("456 Avenue Client")
        expect(result.delivery_address.address.zip).to eq("69001")

        # Project Context
        expect(result.project_context.name).to eq(project.name)
        expect(result.project_context.version).to eq(project_version.number)
        expect(result.project_context.total_amount).to eq(BigDecimal("14"))
        expect(result.project_context.previously_billed_amount).to eq(BigDecimal("0"))

        # Transaction
        expect(result.transaction.total_excl_tax_amount).to eq(BigDecimal("0.05"))
        expect(result.transaction.tax_rate).to eq(BigDecimal("0.2"))
        expect(result.transaction.tax_amount).to eq(BigDecimal("0.01"))
        expect(result.transaction.retention_guarantee_rate).to eq(BigDecimal("0.05"))
        expect(result.transaction.retention_guarantee_amount).to eq(BigDecimal("0.0"))

        expect(result.transaction.items.size).to eq(3)
        expect(result.transaction.items[0]).to have_attributes(
          name: "Super item 1",
          description: "Trés beau garde coprs en galva",
          quantity: 1,
          unit: "ENS",
          unit_price_amount: BigDecimal("1.0"),
          amount: BigDecimal("1.0"),
          previously_invoiced_amount: BigDecimal("0"),
          new_completion_percentage_rate: BigDecimal("0.05")
        )

        expect(result.transaction.item_groups.size).to eq(3)
        expect(result.transaction.item_groups[0]).to have_attributes(
          name: "Item Group 1",
          description: nil,
          position: 1
        )
      end

      context "when dependencies are missing" do
        it "raises an error when project version is missing" do
          completion_snapshot.project_version = nil
          expect { result }.to raise_error(Error::UnprocessableEntityError, "Project version is not defined")
        end

        it "raises an error when project is missing" do
          project_version.project = nil
          expect { result }.to raise_error(Error::UnprocessableEntityError, "Project is not defined")
        end

        it "raises an error when client is missing" do
          project.client = nil
          expect { result }.to raise_error(Error::UnprocessableEntityError, "Client is not defined")
        end

        it "raises an error when company is missing" do
          client.company = nil
          expect { result }.to raise_error(Error::UnprocessableEntityError, "Company is not defined")
        end

        it "raises an error when company config is missing" do
          company.config = nil
          expect { result }.to raise_error(Error::UnprocessableEntityError, "CompanyConfig is not defined")
        end
      end

      context "with default company settings" do
        before { company.config.update!(settings: {}) }

        it "uses default payment terms", :aggregate_failures do
          expect(result.payment_term.days).to eq(CompanyConfig::DEFAULT_SETTINGS.dig("payment_term", "days"))
          expect(result.payment_term.accepted_methods).to eq(CompanyConfig::DEFAULT_SETTINGS.dig("payment_term", "accepted_methods"))
        end
      end
    end
  end
end
