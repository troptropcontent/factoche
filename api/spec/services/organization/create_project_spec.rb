require 'rails_helper'

RSpec.describe Organization::CreateProject do
  describe '.call' do
    let(:company) { FactoryBot.create(:company) }
    let(:client) { FactoryBot.create(:client, company: company) }
    let(:create_project_dto) do
      Organization::CreateProjectDto.new(
        name: project_name,
        client_id: client.id,
        retention_guarantee_rate: retention_guarantee_rate,
        items: items
      )
    end
    let(:project_name) { 'Test Project' }
    let(:retention_guarantee_rate) { 1000 }

    context 'with simple items' do
      let(:items) do
        [
          {
            name: 'Item 1',
            description: 'Description 1',
            position: 1,
            unit: 'piece',
            unit_price_cents: 1000,
            quantity: 2
          },
          {
            name: 'Item 2',
            description: 'Description 2',
            position: 2,
            unit: 'hour',
            unit_price_cents: 2000,
            quantity: 1
          }
        ]
      end

      it 'creates a project with simple items', :aggregate_failures do
        project = described_class.call(create_project_dto)

        expect(project).to be_persisted
        expect(project.name).to eq('Test Project')
        expect(project.client_id).to eq(client.id)

        version = project.versions.first
        expect(version).to be_present
        expect(version.retention_guarantee_rate).to eq(1000)

        expect(version.items.count).to eq(2)
        expect(version.items.first.name).to eq('Item 1')
        expect(version.items.second.name).to eq('Item 2')
      end
    end

    context 'with item groups' do
      let(:items) do
        [
          {
            name: 'Group 1',
            description: 'Group Description',
            position: 1,
            items: [
              {
                name: 'Group Item 1',
                description: 'Group Description 1',
                position: 1,
                unit: 'piece',
                unit_price_cents: 1000,
                quantity: 2
              }
            ]
          }
        ]
      end
      let(:project_name) { 'Test Project with Groups' }

      it 'creates a project with item groups', :aggregate_failures do
        project = described_class.call(create_project_dto)

        expect(project).to be_persisted
        expect(project.name).to eq('Test Project with Groups')

        version = project.versions.first
        expect(version.item_groups.count).to eq(1)

        group = version.item_groups.first
        expect(group.name).to eq('Group 1')
        expect(group.grouped_items.count).to eq(1)
        expect(group.grouped_items.first.name).to eq('Group Item 1')
      end
    end

    context 'with mixed item types' do
      let(:items) do
        [
          {
            name: 'Group 1',
            description: 'Group Description',
            position: 1,
            items: [
              {
                name: 'Group Item 1',
                description: 'Group Description 1',
                position: 1,
                unit: 'piece',
                unit_price_cents: 1000,
                quantity: 2
              }
            ]
          },
          {
            name: 'Item 2',
            description: 'Description 2',
            position: 2,
            unit: 'hour',
            unit_price_cents: 2000,
            quantity: 1
          }
        ]
      end

      it 'raises an error' do
        expect {
          described_class.call(create_project_dto)
        }.to raise_error(
          Error::UnprocessableEntityError,
          "A project can only have one type of item, either simple or groups"
        )
      end
    end

    context 'with invalid data' do
      context 'when there is a validation error on the project' do
        let(:project_name) { '' }
        let(:items) { [] }

        it 'raises ActiveRecord::RecordInvalid and does not create anything', :aggregate_failures do
          expect {
            described_class.call(create_project_dto)
          }.to raise_error(ActiveRecord::RecordInvalid)
          expect(Organization::Project.count).to be_zero
          expect(Organization::ProjectVersion.count).to be_zero
          expect(Organization::Item.count).to be_zero
          expect(Organization::ItemGroup.count).to be_zero
        end
      end

      context 'when there is a validation error on the project version' do
        let(:retention_guarantee_rate) { 100000 }
        let(:items) { [] }

        it 'raises ActiveRecord::RecordInvalid and does not create anything', :aggregate_failures do
          expect {
            described_class.call(create_project_dto)
          }.to raise_error(ActiveRecord::RecordInvalid)
          expect(Organization::Project.count).to be_zero
          expect(Organization::ProjectVersion.count).to be_zero
          expect(Organization::Item.count).to be_zero
          expect(Organization::ItemGroup.count).to be_zero
        end
      end

      context 'when there is a validation error on the items' do
        let(:items) do
          [
            {
              name: 'Duplicate Name',
              description: 'Description 1',
              position: 1,
              unit: 'piece',
              unit_price_cents: 1000,
              quantity: 2
            },
            {
              name: 'Duplicate Name',
              description: 'Description 2',
              position: 2,
              unit: 'hour',
              unit_price_cents: 2000,
              quantity: 1
            }
          ]
        end

        it 'raises ActiveRecord::RecordInvalid and does not create anything', :aggregate_failures do
          expect {
            described_class.call(create_project_dto)
          }.to raise_error(ActiveRecord::RecordInvalid)
          expect(Organization::Project.count).to be_zero
          expect(Organization::ProjectVersion.count).to be_zero
          expect(Organization::Item.count).to be_zero
          expect(Organization::ItemGroup.count).to be_zero
        end
      end

      context 'when there is a validation error on the item_groups' do
        let(:items) do
          [
            {
              name: 'Duplicate Group Name',
              description: 'Group Description',
              position: 1,
              items: [
                {
                  name: 'Group Item 1',
                  description: 'Group Description 1',
                  position: 1,
                  unit: 'piece',
                  unit_price_cents: 1000,
                  quantity: 2
                }
              ]
            },
            {
              name: 'Duplicate Group Name',
              description: 'Group Description',
              position: 1,
              items: [
                {
                  name: 'Group Item 1',
                  description: 'Group Description 1',
                  position: 1,
                  unit: 'piece',
                  unit_price_cents: 1000,
                  quantity: 2
                }
              ]
            }
          ]
        end

        it 'raises ActiveRecord::RecordInvalid and does not create anything', :aggregate_failures do
          expect {
            described_class.call(create_project_dto)
          }.to raise_error(ActiveRecord::RecordInvalid)
          expect(Organization::Project.count).to be_zero
          expect(Organization::ProjectVersion.count).to be_zero
          expect(Organization::Item.count).to be_zero
          expect(Organization::ItemGroup.count).to be_zero
        end
      end
    end
  end
end
