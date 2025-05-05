# rubocop:disable RSpec/MultipleMemoizedHelpers
# rubocop:disable RSpec/ContextWording
RSpec.shared_context 'a company with a quote' do
  let(:company) { FactoryBot.create(:company, :with_config) }
  let(:client) { FactoryBot.create(:client, company: company) }
  let(:project_version_retention_guarantee_rate) { 0.05 }
  ordinals = [ "first", "second", "third" ]
  # Create the quote
  ordinals.each_with_index do |ordinal, index|
    let("#{ordinal}_item_group") { FactoryBot.create(:item_group, project_version: quote_version) }
    let("#{ordinal}_item_unit_price_amount") { (index + 1) }
    let("#{ordinal}_item_quantity") { index + 1 }
    let("#{ordinal}_item_name") { "Super item #{index + 1}" }
    let("#{ordinal}_item_unit") { "ENS" }
  end
  let(:create_quote_params) { {
    name: "New hall in Biarritz",
    description: "A brand new hall for the police station",
    retention_guarantee_rate: project_version_retention_guarantee_rate,
    items: ordinals.map.with_index { |ordinal, index|  {
      name: send("#{ordinal}_item_name"),
      quantity: send("#{ordinal}_item_quantity"),
      unit: send("#{ordinal}_item_unit"),
      unit_price_amount: send("#{ordinal}_item_unit_price_amount"),
      position: index,
      tax_rate: 0.2
    }},
    groups: []
  }}
  let(:quote) { Organization::Quotes::Create.call(company.id, client.id, create_quote_params).data }
  let(:quote_version) { quote.last_version }
  ordinals.each_with_index do |ordinal, index|
    let("#{ordinal}_item") { quote_version.items[index] }
  end
end
# rubocop:enable RSpec/ContextWording
# rubocop:enable RSpec/MultipleMemoizedHelpers
