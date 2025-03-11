# rubocop:disable RSpec/ContextWording
# rubocop:disable RSpec/MultipleMemoizedHelpers
# rubocop:disable RSpec/LetSetup
RSpec.shared_context 'a company with a project with three items' do
  let(:company) { FactoryBot.create(:company, :with_config) }
  let(:client) { FactoryBot.create(:client, company: company) }
  let(:project) { FactoryBot.create(:project, client: client) }
  let(:project_version) { FactoryBot.create(:project_version, project: project, retention_guarantee_rate: project_version_retention_guarantee_rate) }
  let(:project_version_retention_guarantee_rate) { 500 }
  ordinals = [ "first", "second", "third" ]

  ordinals.each_with_index do |ordinal, index|
    let("#{ordinal}_item_group") { FactoryBot.create(:item_group, project_version: project_version) }
    let("#{ordinal}_item_unit_price_cents") { 100 * (index + 1) }
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
        unit_price_cents: send("#{ordinal}_item_unit_price_cents"),
        unit: send("#{ordinal}_item_unit"),
        original_item_uuid: SecureRandom.uuid)
    end
  end
end
