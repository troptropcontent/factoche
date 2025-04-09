# rubocop:disable RSpec/MultipleMemoizedHelpers
# rubocop:disable RSpec/ContextWording
# rubocop:disable RSpec/LetSetup
require_relative "a_company_with_a_draft_order"

RSpec.shared_context 'a company with an order' do
  include_context 'a company with a draft order'
  let(:order) { Organization::DraftOrders::ConvertToOrder.call(draft_order.id).data }
  let!(:order_version) { order.last_version }
end
# rubocop:enable RSpec/LetSetup
# rubocop:enable RSpec/ContextWording
# rubocop:enable RSpec/MultipleMemoizedHelpers
