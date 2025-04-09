# rubocop:disable RSpec/MultipleMemoizedHelpers
# rubocop:disable RSpec/ContextWording
RSpec.shared_context 'a company with a quote' do
  let(:company) { FactoryBot.create(:company, :with_config) }
  let(:client) { FactoryBot.create(:client, company: company) }
  let(:project_version_retention_guarantee_rate) { 0.05 }
  ordinals = [ "first", "second", "third" ]
  # Create the quote
  let(:quote) { FactoryBot.create(:quote, client: client, company: company) }
  let(:quote_version) { FactoryBot.create(:project_version, project: quote, retention_guarantee_rate: project_version_retention_guarantee_rate) }
  ordinals.each_with_index do |ordinal, index|
    let("#{ordinal}_item_group") { FactoryBot.create(:item_group, project_version: quote_version) }
    let("#{ordinal}_item_unit_price_amount") { (index + 1) }
    let("#{ordinal}_item_quantity") { index + 1 }
    let("#{ordinal}_item_name") { "Super item #{index + 1}" }
    let("#{ordinal}_item_unit") { "ENS" }
    # rubocop:disable RSpec/LetSetup
    let!("#{ordinal}_item") do
      FactoryBot.create(
        :item,
        project_version: quote_version,
        name: send("#{ordinal}_item_name"),
        item_group: send("#{ordinal}_item_group"),
        quantity: send("#{ordinal}_item_quantity"),
        unit_price_amount: send("#{ordinal}_item_unit_price_amount"),
        unit: send("#{ordinal}_item_unit"),
        original_item_uuid: SecureRandom.uuid)
    end
  end
end
# rubocop:enable RSpec/ContextWording
# rubocop:enable RSpec/MultipleMemoizedHelpers
