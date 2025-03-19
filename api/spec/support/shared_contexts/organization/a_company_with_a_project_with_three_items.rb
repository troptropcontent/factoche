# rubocop:disable RSpec/ContextWording
# rubocop:disable RSpec/MultipleMemoizedHelpers
# rubocop:disable RSpec/LetSetup
RSpec.shared_context 'a company with a project with three items' do
  let(:company) { FactoryBot.create(:company, :with_config) }
  let(:client) { FactoryBot.create(:client, company: company) }
  let(:quote) { FactoryBot.create(:quote, client: client) }
  let(:quote_version) { FactoryBot.create(:project_version, project: quote, retention_guarantee_rate: project_version_retention_guarantee_rate) }
  let(:project) { FactoryBot.create(:order, client: client, original_quote_version: quote_version) }
  let(:project_version) { FactoryBot.create(:project_version, project: project, retention_guarantee_rate: project_version_retention_guarantee_rate) }
  let(:order) { project }
  let(:order_version) { project_version }
  let(:project_version_retention_guarantee_rate) { 0.05 }
  ordinals = [ "first", "second", "third" ]

  ordinals.each_with_index do |ordinal, index|
    let("#{ordinal}_item_group") { FactoryBot.create(:item_group, project_version: project_version) }
    let("#{ordinal}_item_unit_price_amount") { (index + 1) }
    let("#{ordinal}_item_quantity") { index + 1 }
    let("#{ordinal}_item_name") { "Super item #{index + 1}" }
    let("#{ordinal}_item_unit") { "ENS" }
    # rubocop:disable RSpec/LetSetup
    let!("#{ordinal}_item") do
      FactoryBot.create(
        :item,
        project_version: project_version,
        name: send("#{ordinal}_item_name"),
        item_group: send("#{ordinal}_item_group"),
        quantity: send("#{ordinal}_item_quantity"),
        unit_price_amount: send("#{ordinal}_item_unit_price_amount"),
        unit: send("#{ordinal}_item_unit"),
        original_item_uuid: SecureRandom.uuid)
    end
  end
end
