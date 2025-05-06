require 'rails_helper'
require 'support/shared_contexts/organization/projects/a_company_with_an_order'

RSpec.describe Accounting::Payment, type: :model do
  describe "validations" do
    subject(:payment) { described_class.new(invoice: invoice, received_at: Time.current, amount: 0.2) }

    include_context 'a company with an order'

    let(:invoice) {
      proforma = Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data
      Accounting::Proformas::Post.call(proforma.id).data
    }

    it { is_expected.to belong_to(:invoice).class_name("Accounting::Invoice") }
  it { is_expected.to validate_presence_of(:amount) }
  it { is_expected.to validate_numericality_of(:amount).is_greater_than(0) }
  it { is_expected.to validate_presence_of(:received_at) }
  end
end
