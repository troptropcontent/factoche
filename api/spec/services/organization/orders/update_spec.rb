require 'rails_helper'
require 'services/shared_examples/service_result_example'

RSpec.describe Organization::Orders::Update do
  subject(:result) { described_class.call(*args) }

  let(:args) { [ order.id, params ] }
  let(:company) { FactoryBot.create(:company, :with_bank_detail) }
  let(:client) { FactoryBot.create(:client, company: company) }
  let(:quote) { FactoryBot.create(:quote, :with_version, company: company, client: client) }
  let(:draft_order) { Organization::Quotes::ConvertToDraftOrder.call(quote.id).data }
  let!(:order) { Organization::DraftOrders::ConvertToOrder.call(draft_order.id).data }
  let(:params) do
    {
      name: "Updated Order Name",
      description: "Updated description",
      retention_guarantee_rate: 0.05,
      bank_detail_id: company.bank_details.last.id,
      new_items: [ {
        name: "New Item",
        description: "New Item Description",
        position: 1,
        quantity: 2,
        unit: "hours",
        unit_price_amount: 100.0,
        tax_rate: 0.2
      } ],
      updated_items: [],
      groups: []
    }
  end

  describe '#call', :aggregate_failures do
    context 'when order is updatable' do
      it { is_expected.to be_success }

      it 'updates the order successfully' do
        expect(result.data).to be_a(Organization::Order)
        expect(result.data.name).to eq("Updated Order Name")
        expect(result.data.description).to eq("Updated description")
      end

      it 'creates a new version' do
        expect { result }
          .to change(Organization::ProjectVersion, :count).by(1)
          .and change(Organization::Item, :count).by(1)
      end

      it 'enqueue a new job to generate its pdf' do
        expect { result }
        .to change(Organization::ProjectVersions::GeneratePdfJob.jobs, :size).by(1)
      end
    end

    context 'with items' do
      let!(:existing_item) do
        FactoryBot.create(:item,
          project_version: order.versions.first,
          original_item_uuid: SecureRandom.uuid,
          name: "Original Item",
          description: "Original Description",
          unit: "days"
        )
      end

      let(:params) do
        {
          name: "Updated Order Name",
          retention_guarantee_rate: 0.05,
          bank_detail_id: company.bank_details.last.id,
          updated_items: [
            {
              original_item_uuid: existing_item.original_item_uuid,
              quantity: 2,
              unit_price_amount: 100.0,
              position: 1,
              tax_rate: 0.2
            }
          ],
          new_items: [
            {
              name: "New Item",
              description: "New Description",
              unit: "hours",
              quantity: 1,
              unit_price_amount: 50.0,
              position: 2,
              tax_rate: 0.2
            }
          ],
          groups: []
        }
      end

      it_behaves_like 'a success'

      it 'create new items with relevant attributes' do
        updated_order = result.data
        new_version = updated_order.versions.last
        updated_item = new_version.items.find_by(original_item_uuid: existing_item.original_item_uuid)
        expect(updated_item).to have_attributes(
          name: "Original Item",
          description: "Original Description",
          unit: "days",
          quantity: 2,
          unit_price_amount: 100.0,
          tax_rate: 0.2
        )

        new_item = new_version.items.find_by(name: "New Item")
        expect(new_item).to have_attributes(
          description: "New Description",
          unit: "hours",
          quantity: 1,
          unit_price_amount: 50.0,
          tax_rate: 0.2
        )
      end

      context 'with invalid original_item_uuid' do
        let(:params) do
          {
            name: "Updated Order Name",
            retention_guarantee_rate: 0.05,
            bank_detail_id: company.bank_details.last.id,
            updated_items: [
              {
                original_item_uuid: "non-existent-uuid",
                quantity: 2,
                unit_price_amount: 100.0,
                tax_rate: 0.2
              }
            ],
            groups: []
          }
        end

        it_behaves_like 'a failure'
      end
    end

    context 'with groups and items' do
      let(:params) do
        {
          name: "Updated Order Name",
          retention_guarantee_rate: 0.05,
          bank_detail_id: company.bank_details.last.id,
          groups: [
            {
              uuid: "group-1",
              name: "Group 1",
              description: "First group",
              position: 1
            },
            {
              uuid: "group-2",
              name: "Group 2",
              description: "Second group",
              position: 2
            }
          ],
          new_items: [
            {
              name: "New Item in Group 1",
              description: "Description",
              unit: "hours",
              quantity: 1,
              unit_price_amount: 50.0,
              position: 1,
              tax_rate: 0.2,
              group_uuid: "group-1"
            },
            {
              name: "New Item in Group 2",
              description: "Description",
              unit: "days",
              quantity: 2,
              unit_price_amount: 100.0,
              position: 2,
              tax_rate: 0.2,
              group_uuid: "group-2"
            }
          ],
          updated_items: []
        }
      end

      it_behaves_like 'a success'

      it 'creates items with correct group associations' do
        updated_order = result.data
        new_version = updated_order.versions.last

        group1 = new_version.item_groups.find_by!(name: "Group 1")
        group1_items = group1.grouped_items
        expect(group1_items.count).to eq(1)
        expect(group1_items.first).to have_attributes(
          name: "New Item in Group 1",
        )

        group2 = new_version.item_groups.find_by!(name: "Group 2")
        group2_items = group2.grouped_items
        expect(group2_items.count).to eq(1)
        expect(group2_items.first).to have_attributes(
          name: "New Item in Group 2",
        )
      end

      context 'with invalid group references' do
        let(:params) do
          {
            name: "Updated Order Name",
            retention_guarantee_rate: 0.05,
            bank_detail_id: company.bank_details.last.id,
            groups: [
              {
                uuid: "group-1",
                name: "Group 1",
                description: "First group",
                position: 1
              }
            ],
            new_items: [
              {
                name: "New Item",
                description: "Description",
                unit: "hours",
                quantity: 1,
                unit_price_amount: 50.0,
                position: 1,
                tax_rate: 0.2,
                group_uuid: "non-existent-group"
              }
            ],
            updated_items: []
          }
        end

        it_behaves_like 'a failure'
      end

      context 'with empty group' do
        let(:params) do
          {
            name: "Updated Order Name",
            retention_guarantee_rate: 0.05,
            bank_detail_id: company.bank_details.last.id,
            groups: [
              {
                uuid: "empty-group",
                name: "Empty Group",
                description: "Group with no items",
                position: 1
              }
            ],
            new_items: [
              {
                name: "New Item",
                description: "Description",
                unit: "hours",
                quantity: 1,
                unit_price_amount: 50.0,
                position: 1,
                tax_rate: 0.2
                # no group_uuid
              }
            ],
            updated_items: []
          }
        end

        it_behaves_like 'a failure'
      end
    end
  end
end
