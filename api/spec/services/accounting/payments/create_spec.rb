require "rails_helper"
require 'support/shared_contexts/organization/projects/a_company_with_some_orders'
require 'services/shared_examples/service_result_example'

RSpec.describe Accounting::Payments::Create do
  describe "#call" do
    subject(:result) { described_class.call(arg_invoice_id, arg_received_at) }

    include_context 'a company with some orders', number_of_orders: 2

    let(:proforma) do
      ::Organization::Proformas::Create.call(first_order.last_version.id, {
        invoice_amounts: [
          { original_item_uuid: first_order.last_version.items.first.original_item_uuid, invoice_amount: 1 },
          { original_item_uuid: first_order.last_version.items.second.original_item_uuid, invoice_amount: 2 }
        ]
      }).data
    end

    let(:invoice) { ::Accounting::Proformas::Post.call(proforma.id).data }

    let(:arg_invoice_id) { invoice.id }
    let(:arg_received_at) { Time.current }

    context "when the invoice exists" do
      context "when the payment is recorded successfuly" do
        it_behaves_like 'a success'

        it "creates a payment with the correct attributes", :aggregate_failures do
          payment = result.data

          expect(payment).to be_a(Accounting::Payment)
          expect(payment.invoice).to eq(invoice)
          expect(payment.amount).to eq(invoice.total_excl_retention_guarantee_amount)
          expect(payment.received_at).to be_within(1).of(Time.current)
        end
      end

      context "when the payment is not recorded successfully" do
        before {
          allow(Accounting::Payment).to receive(:create!).and_raise("Database error")
        }

        it_behaves_like 'a failure', "Database error"
      end
    end

    context "when invoice is not found" do
      let(:arg_invoice_id) { -1 }

      it_behaves_like 'a failure', "Couldn't find Accounting::Invoice with 'id'=-1"
    end
  end
end
