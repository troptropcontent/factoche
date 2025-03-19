# rubocop:disable RSpec/ContextWording
# rubocop:disable RSpec/MultipleMemoizedHelpers
# rubocop:disable RSpec/LetSetup
RSpec.shared_context 'a company with a project with three item groups' do
  let(:company) { FactoryBot.create(:company) }
  let!(:company_config) { FactoryBot.create(:company_config, company: company) }
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
    let("project_version_#{ordinal}_item_group") { FactoryBot.create(:item_group, project_version: project_version) }
    let("project_version_#{ordinal}_item_group_item_unit_price_amount") { 100 * (index + 1) }
    let("project_version_#{ordinal}_item_group_item_unit_quantity") { index + 1 }
    let("project_version_#{ordinal}_item_group_item_name") { "Super item #{index + 1}" }
    let("project_version_#{ordinal}_item_group_item_unit") { "ENS" }
    # rubocop:disable RSpec/LetSetup
    let!("project_version_#{ordinal}_item_group_item") do
      FactoryBot.create(
        :item,
        project_version: project_version,
        name: send("project_version_#{ordinal}_item_group_item_name"),
        item_group: send("project_version_#{ordinal}_item_group"),
        quantity: send("project_version_#{ordinal}_item_group_item_unit_quantity"),
        unit_price_amount: send("project_version_#{ordinal}_item_group_item_unit_price_amount"),
        unit: send("project_version_#{ordinal}_item_group_item_unit"),
        original_item_uuid: SecureRandom.uuid)
    end
    let("#{ordinal}_item") { send("project_version_#{ordinal}_item_group_item") }
  end
end
