require 'rails_helper'

RSpec.describe Organization::Projects::Update do
  subject(:result) { described_class.call(project, params) }

  let(:company) { FactoryBot.create(:company) }
  let(:first_bank_detail) { FactoryBot.create(:bank_detail, company: company) }
  let(:second_bank_detail) { FactoryBot.create(:bank_detail, company: company) }

  let(:client) { FactoryBot.create(:client, company: company) }
  let(:project) { FactoryBot.create(:project, company: company, client: client, type: "Organization::Quote") }
  let(:project_version) { FactoryBot.create(:project_version, project: project) }
  let!(:existing_item) do
    FactoryBot.create(:item,
      project_version: project_version,
      original_item_uuid: SecureRandom.uuid,
      name: "Original Item",
      description: "Original Description",
      unit: "days"
    )
  end

  describe '#call', :aggregate_failures do
  [ Organization::Quote, Organization::Order, Organization::DraftOrder ].each do |project_class|
    let(:project) { FactoryBot.create(:project, company: company, client: client, type: project_class.name, bank_detail: first_bank_detail) }
    context "when the project is a #{project_class}" do
      context 'with valid params' do
        let(:params) do
          {
            name: "Updated Project",
            description: "New description",
            retention_guarantee_rate: 0.05,
            bank_detail_id: second_bank_detail.id,
            new_items: [
              {
                name: "New Item",
                description: "New Item Description",
                position: 1,
                quantity: 2,
                unit: "hours",
                unit_price_amount: 100.0,
                tax_rate: 0.2
              }
            ],
            updated_items: [
              {
                original_item_uuid: existing_item.original_item_uuid,
                position: 2,
                quantity: 3,
                unit_price_amount: 150.0,
                tax_rate: 0.2
              }
            ],
            groups: []
          }
        end

        it 'updates the project and creates a new version' do
          expect(result).to be_success
          expect(result.data[:project].name).to eq "Updated Project"
          expect(result.data[:project].description).to eq "New description"
          expect(result.data[:project].bank_detail_id).to eq second_bank_detail.id

          new_version = result.data[:version]
          expect(new_version).to be_persisted
          expect(new_version.retention_guarantee_rate).to eq 0.05
        end

        it 'forwards general terms and conditions to the new version' do
        expect(result.data[:version].general_terms_and_conditions).to eq(project_version.general_terms_and_conditions)
      end

        it 'creates new items and updates existing ones' do
          new_version = result.data[:version]

          # Check new items
          new_item = new_version.items.find_by(name: "New Item")
          expect(new_item).to have_attributes(
            description: "New Item Description",
            position: 1,
            quantity: 2,
            unit: "hours",
            unit_price_amount: 100.0,
            tax_rate: 0.2
          )

          # Check updated items
          updated_item = new_version.items.find_by(original_item_uuid: existing_item.original_item_uuid)
          expect(updated_item).to have_attributes(
            name: existing_item.name,           # Should keep original name
            description: existing_item.description, # Should keep original description
            unit: existing_item.unit,          # Should keep original unit
            position: 2,                       # Should update position
            quantity: 3,                       # Should update quantity
            unit_price_amount: 150.0,          # Should update price
            tax_rate: 0.2                      # Should update tax rate
          )
        end
      end

      context 'with invalid original_item_uuid' do
        let(:params) do
          {
            name: "Updated Project",
            retention_guarantee_rate: 0.05,
            bank_detail_id: company.bank_details.last.id,
            new_items: [],
            updated_items: [
              {
                original_item_uuid: "cbbca938-b0f6-43ed-b363-f7bd6e7f5453", # Random non-existent UUID
                position: 1,
                quantity: 2,
                unit_price_amount: 100.0,
                tax_rate: 0.2
              }
            ],
            groups: []
          }
        end

        it 'returns failure result' do
          expect(result).to be_failure
          expect(result.error).to be_a(Error::UnprocessableEntityError)
          expect(result.error.message).to include("The following original_item_uuids are invalid: cbbca938-b0f6-43ed-b363-f7bd6e7f5453")
        end
      end

      context 'with invalid params' do
        let(:params) do
          {
            name: "",  # Invalid: empty name
            retention_guarantee_rate: 0.05,
            bank_detail_id: company.bank_details.last.id,
            new_items: [],
            updated_items: [],
            groups: []
          }
        end

        it 'returns validation error' do
          expect(result).to be_failure
          expect(result.error).to be_a(Error::UnprocessableEntityError)
        end
      end

      context 'with groups' do
        let(:group_uuid) { SecureRandom.uuid }
        let(:params) do
          {
            name: "Updated Project",
            retention_guarantee_rate: 0.05,
            bank_detail_id: company.bank_details.last.id,
            new_items: [
              {
                name: "New Item",
                description: "New Item Description",
                position: 1,
                quantity: 2,
                unit: "hours",
                unit_price_amount: 100.0,
                tax_rate: 0.2,
                group_uuid: group_uuid
              }
            ],
            updated_items: [
              {
                original_item_uuid: existing_item.original_item_uuid,
                position: 2,
                quantity: 3,
                unit_price_amount: 150.0,
                tax_rate: 0.2,
                group_uuid: group_uuid
              }
            ],
            groups: [
              {
                uuid: group_uuid,
                name: "Test Group",
                description: "Group Description",
                position: 1
              }
            ]
          }
        end

        it 'creates groups and associates items' do
          expect(result).to be_success
          new_version = result.data[:version]

          group = new_version.item_groups.first
          expect(group).to have_attributes(
            name: "Test Group",
            description: "Group Description",
            position: 1
          )

          expect(group.grouped_items.count).to eq 2
          expect(group.grouped_items.pluck(:name)).to include("New Item", existing_item.name)
        end
      end
    end
  end
  end
end
