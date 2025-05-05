# rubocop:disable RSpec/MultipleMemoizedHelpers
# rubocop:disable RSpec/ContextWording
RSpec.shared_context 'a company with some quotes' do |number_of_quotes: 1|
  let(:company) { FactoryBot.create(:company, :with_config) }
  ordinals = [ "first", "second", "third" ]

  if number_of_quotes > ordinals.length
    raise "Achtung, max number of quote that can be created is #{ordinals.length}"
  end

  number_of_quotes.times do |number_of_quote_index|
    let("#{ordinals[number_of_quote_index]}_client") { FactoryBot.create(:client, company: company) }
    let("#{ordinals[number_of_quote_index]}_quote_version_retention_guarantee_rate") { 0.05 }
    # Create the quote
    ordinals.each_with_index do |ordinal, index|
      let("#{ordinals[number_of_quote_index]}_quote_#{ordinal}_item_unit_price_amount") { (index + 1) }
      let("#{ordinals[number_of_quote_index]}_quote_#{ordinal}_item_quantity") { index + 1 }
      let("#{ordinals[number_of_quote_index]}_quote_#{ordinal}_item_name") { "Super item #{index + 1}" }
      let("#{ordinals[number_of_quote_index]}_quote_#{ordinal}_item_unit") { "ENS" }
    end
    let("#{ordinals[number_of_quote_index].capitalize}_create_quote_params") { {
      name: "#{ordinals[number_of_quote_index].capitalize} new hall in Biarritz",
      description: "A brand new hall for the police station",
      retention_guarantee_rate: send("#{ordinals[number_of_quote_index]}_quote_version_retention_guarantee_rate"),
      items: ordinals.map.with_index { |ordinal, index|  {
        name: send("#{ordinals[number_of_quote_index]}_quote_#{ordinal}_item_name"),
        quantity: send("#{ordinals[number_of_quote_index]}_quote_#{ordinal}_item_quantity"),
        unit: send("#{ordinals[number_of_quote_index]}_quote_#{ordinal}_item_unit"),
        unit_price_amount: send("#{ordinals[number_of_quote_index]}_quote_#{ordinal}_item_unit_price_amount"),
        position: index,
        tax_rate: 0.2
      }},
      groups: []
    }}
    let("#{ordinals[number_of_quote_index]}_quote") { Organization::Quotes::Create.call(company.id, send("#{ordinals[number_of_quote_index]}_client").id, send("#{ordinals[number_of_quote_index].capitalize}_create_quote_params")).data }
    let!("#{ordinals[number_of_quote_index]}_quote_version") { send("#{ordinals[number_of_quote_index]}_quote").last_version }
    ordinals.each_with_index do |ordinal, index|
      let("#{ordinals[number_of_quote_index]}_quote_#{ordinal}_item") { quote_version.items[index] }
    end
  end
end
# rubocop:enable RSpec/ContextWording
# rubocop:enable RSpec/MultipleMemoizedHelpers
