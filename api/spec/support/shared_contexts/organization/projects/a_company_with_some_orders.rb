# rubocop:disable RSpec/MultipleMemoizedHelpers
# rubocop:disable RSpec/ContextWording
# rubocop:disable RSpec/LetSetup
require_relative "a_company_with_some_draft_orders"

RSpec.shared_context 'a company with some orders' do |number_of_orders: 1|
  include_context 'a company with some draft orders', number_of_draft_orders: number_of_orders

  ordinals = [ "first", "second", "third" ]
  ordinals.each do |ordinal|
    let!("#{ordinal}_order") { Organization::DraftOrders::ConvertToOrder.call(send("#{ordinal}_draft_order").id).data }
    let("#{ordinal}_order_version") { send("#{ordinal}_order").last_version }
  end
end
# rubocop:enable RSpec/LetSetup
# rubocop:enable RSpec/ContextWording
# rubocop:enable RSpec/MultipleMemoizedHelpers
