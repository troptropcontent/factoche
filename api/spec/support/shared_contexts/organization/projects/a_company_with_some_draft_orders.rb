# rubocop:disable RSpec/MultipleMemoizedHelpers
# rubocop:disable RSpec/ContextWording
require_relative "a_company_with_some_quotes"
RSpec.shared_context 'a company with some draft orders' do |number_of_draft_orders: 1|
  include_context "a company with some quotes", number_of_quotes: number_of_draft_orders
  ordinals = [ "first", "second", "third" ]

  ordinals.each do |ordinal|
    let!("#{ordinal}_draft_order") { Organization::Quotes::ConvertToDraftOrder.call(send("#{ordinal}_quote").id).data }
    let("#{ordinal}_draft_order_version") { send("#{ordinal}_draft_order").last_version }
  end
end
# rubocop:enable RSpec/ContextWording
# rubocop:enable RSpec/MultipleMemoizedHelpers
