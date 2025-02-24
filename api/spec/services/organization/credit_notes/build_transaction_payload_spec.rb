require "rails_helper"

module Organization
  RSpec.describe CreditNotes::BuildTransactionPayload do
    subject(:result) { described_class.call(agument) }
    let(:agument) { original_invoice }

    describe "#call" do
      let(:invoice_payload) do
        {
          "transaction" => {
            "total_excl_tax_amount" => "1000.00",
            "tax_rate" => "0.20",
            "tax_amount" => "200.00",
            "retention_guarantee_amount" => "100.00",
            "retention_guarantee_rate" => "0.10",
            "invoice_total_amount" => "1200.00",
            "item_groups" => [ { "id" => "group1" } ],
            "items" => [
              {
                "id" => "item1",
                "original_item_uuid" => "uuid1",
                "name" => "Item 1",
                "description" => "Description 1",
                "item_group_id" => "group1",
                "quantity" => 2,
                "unit" => "hours",
                "unit_price_amount" => "100.00",
                "invoice_amount" => "200.00"
              }
            ]
          }
        }
      end

      let(:original_invoice) { instance_double(Invoice, payload: invoice_payload) }

      context "when given valid input" do
        let(:item) { result.items.first }

        it "returns a Result object with correct attributes", :aggregate_failures do
          expect(result).to be_a(described_class::Result)
          expect(result.total_excl_tax_amount).to eq("1000.00")
          expect(result.tax_rate).to eq("0.20")
          expect(result.tax_amount).to eq("200.00")
          expect(result.retention_guarantee_amount).to eq("100.00")
          expect(result.retention_guarantee_rate).to eq("0.10")
          expect(result.item_groups).to eq([ { "id" => "group1" } ])
          expect(result.credit_note_total_amount).to eq("1200.00")
        end

        it "correctly maps items", :aggregate_failures do
          expect(item).to be_a(described_class::Item)
          expect(item.id).to eq("item1")
          expect(item.original_item_uuid).to eq("uuid1")
          expect(item.name).to eq("Item 1")
          expect(item.description).to eq("Description 1")
          expect(item.item_group_id).to eq("group1")
          expect(item.quantity).to eq(2)
          expect(item.unit).to eq("hours")
          expect(item.unit_price_amount).to eq("100.00")
          expect(item.credit_note_amount).to eq("200.00")
        end
      end

      describe "when input is invalid" do
        context "when the argument is nil" do
          let(:agument) { nil }

          it "raises ArgumentError when original invoice is nil" do
            expect { result }.to raise_error(
              ArgumentError,
              "Original invoice is required"
            )
          end
        end

        context "when the payload is invalid" do
          context "when the payload is not an hash" do
            let(:original_invoice) { instance_double(Invoice, payload: "not an hash") }

            it "raises ArgumentError when invoice payload is not a hash" do
              expect { result }.to raise_error(
                ArgumentError,
                "Invalid invoice payload"
              )
            end
          end

          context "when the payload is an hash but do not have the right structure" do
            let(:original_invoice) { instance_double(Invoice, payload: { "something_else" => {} }) }

            it "raises ArgumentError when transaction is missing" do
              expect { result }.to raise_error(
                ArgumentError,
                "Invalid invoice payload"
              )
            end
          end

          context "when some keys are missing in the invoice payload" do
            let(:original_invoice) do
              instance_double(Invoice, payload: {
                "transaction" => {
                  "total_excl_tax_amount" => "1000.00",
                  "items" => [
                    {
                      "id" => "item1"
                    }
                  ]
                }
              })
            end

            it "raises ArgumentError when required item fields are missing" do
              expect { result }.to raise_error(
                ArgumentError,
                /Missing required field/
              )
            end
          end
        end
      end
    end
  end
end
