require 'rails_helper'

RSpec.describe Organization::ProjectVersions::Create do
  subject(:result) { described_class.call(project, params) }

  let(:company) { FactoryBot.create(:company) }
  let(:client) { FactoryBot.create(:client, company: company) }

  # rubocop:disable RSpec/NestedGroups
  # rubocop:disable RSpec/MultipleMemoizedHelpers
  # rubocop:disable RSpec/ExampleLength
  describe '#call' do
    [ Organization::Quote, Organization::Order, Organization::DraftOrder ].each do |project_class|
      let(:project) { FactoryBot.create(:project, company: company, client: client, type: project_class.name) }
      context "when the project is a #{project_class}" do
        context 'with valid params' do
          context 'without groups' do
            let(:params) do
              {
                retention_guarantee_rate: 0.05,
                items: [
                  {
                    name: 'Item 1',
                    description: 'Description 1',
                    position: 1,
                    quantity: 2,
                    unit: 'days',
                    unit_price_amount: 100.0,
                    tax_rate: 0.2
                  }
                ],
                groups: []
              }
            end

            it 'creates a new version with items', :aggregate_failures do
              expect(result).to be_success
              expect(result.data[:version]).to be_persisted
              expect(result.data[:version].retention_guarantee_rate).to eq 0.05
              expect(result.data[:version].total_excl_tax_amount).to eq 200
              expect(result.data[:groups]).to be_empty

              item = result.data[:items].first
              expect(item.name).to eq 'Item 1'
              expect(item.description).to eq 'Description 1'
              expect(item.position).to eq 1
              expect(item.quantity).to eq 2
              expect(item.unit).to eq 'days'
              expect(item.unit_price_amount).to eq 100.0
              expect(item.tax_rate).to eq 0.2
              expect(item.original_item_uuid).to be_present
              expect(item.item_group).to be_nil
            end
          end

          context 'with groups' do
            let(:group_uuid) { SecureRandom.uuid }
            let(:params) do
              {
                retention_guarantee_rate: 0.05,
                items: [
                  {
                    name: 'Item 1',
                    description: 'Description 1',
                    position: 1,
                    quantity: 2,
                    unit: 'days',
                    unit_price_amount: 100.0,
                    tax_rate: 0.2,
                    group_uuid: group_uuid
                  }
                ],
                groups: [
                  {
                    uuid: group_uuid,
                    name: 'Group 1',
                    description: 'Group Description',
                    position: 1
                  }
                ]
              }
            end

            it 'creates a new version with grouped items', :aggregate_failures do
              expect(result).to be_success
              expect(result.data[:version]).to be_persisted
              expect(result.data[:items].count).to eq 1
              expect(result.data[:groups].count).to eq 1

              group = result.data[:groups].first
              expect(group.name).to eq 'Group 1'
              expect(group.description).to eq 'Group Description'
              expect(group.position).to eq 1

              item = result.data[:items].first
              expect(item.name).to eq 'Item 1'
              expect(item.item_group).to eq group
            end
          end

          context 'when original_item_uuid is provided for some items' do
            context "when the original_item_uuid belongs to a previous version of the project" do
              let(:project_version) { FactoryBot.create(:project_version, project: project, total_excl_tax_amount: 0) }
              let(:project_version_item) { FactoryBot.create(:item, project_version: project_version, original_item_uuid: "2bd8f435-dd31-41d1-a0bc-7cffb3b72fb1") }
              let(:params) do
                {
                  retention_guarantee_rate: 0.05,
                  items: [
                    {
                      name: 'Item 1',
                      description: 'Description 1',
                      position: 1,
                      quantity: 2,
                      unit: 'days',
                      unit_price_amount: 100.0,
                      tax_rate: 0.2,
                      original_item_uuid: project_version_item.original_item_uuid
                    }
                  ],
                  groups: []
                }
              end

              it 'forward the original_item_uuid to the new item', :aggregate_failures do
                expect(result).to be_success
                item = result.data[:items].first
                expect(item.original_item_uuid).to eq "2bd8f435-dd31-41d1-a0bc-7cffb3b72fb1"
              end
            end

            context "when the original_item_uuid does not belongs to a previous version of the project" do
              let(:params) do
                {
                  retention_guarantee_rate: 0.05,
                  items: [
                    {
                      name: 'Item 1',
                      description: 'Description 1',
                      position: 1,
                      quantity: 2,
                      unit: 'days',
                      unit_price_amount: 100.0,
                      tax_rate: 0.2,
                      original_item_uuid: "2bd8f435-dd31-41d1-a0bc-7cffb3b72fb1"
                    }
                  ],
                  groups: []
                }
              end

              it 'forward the original_item_uuid to the new item', :aggregate_failures do
                expect(result).to be_failure
                expect(result.error.message).to include("The following original_item_uuids are invalid: 2bd8f435-dd31-41d1-a0bc-7cffb3b72fb1")
              end
            end
          end
        end

        context 'with invalid params' do
          let(:params) do
            {
              retention_guarantee_rate: nil,
              items: []
            }
          end

          it 'returns failure result', :aggregate_failures do
            expect(result).to be_failure
            expect(result.error).to be_a(Error::UnprocessableEntityError)
          end

          context 'with invalid group references' do
            let(:params) do
              {
                retention_guarantee_rate: 0.05,
                items: [
                  {
                    name: 'Item 1',
                    description: 'Description 1',
                    position: 1,
                    quantity: 2,
                    unit: 'days',
                    unit_price_amount: 100.0,
                    tax_rate: 0.2,
                    group_uuid: 'non-existent-uuid'
                  }
                ],
                groups: [
                  {
                    uuid: SecureRandom.uuid,
                    name: 'Group 1',
                    description: 'Group Description',
                    position: 1
                  }
                ]
              }
            end

            it 'returns failure result', :aggregate_failures  do
              expect(result).to be_failure
              expect(result.error).to be_a(Error::UnprocessableEntityError)
            end
          end
        end
      end
    end
  end
  # rubocop:enable RSpec/ExampleLength
  # rubocop:enable RSpec/MultipleMemoizedHelpers
  # rubocop:enable RSpec/NestedGroups
end
