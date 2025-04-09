# rubocop:disable RSpec/MultipleMemoizedHelpers
# rubocop:disable RSpec/ContextWording
require_relative "a_company_a_quote"
RSpec.shared_context 'a company with a draft order' do
  include_context "a company with a quote"
  let(:draft_order) { Organization::Quotes::ConvertToDraftOrder.call(quote.id).data }
  let(:draft_order_version) { draft_order.last_version }
end
# rubocop:enable RSpec/ContextWording
# rubocop:enable RSpec/MultipleMemoizedHelpers
