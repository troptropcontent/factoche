require 'rails_helper'
require 'services/shared_examples/service_result_example'

RSpec.describe Organization::Quotes::Update do
  subject(:result) { described_class.call(quote, params) }

  let(:company) { FactoryBot.create(:company) }
  let(:client) { FactoryBot.create(:client, company: company) }
  let(:quote) { FactoryBot.create(:quote, company: company, client: client) }
  let(:quote_version) { FactoryBot.create(:project_version, project: quote) }
  let(:params) do
    {
      name: "Updated Quote Name",
      description: "Updated description",
      retention_guarantee_rate: 0.05,
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
    context 'when quote is updatable' do
      it { is_expected.to be_success }

      it 'updates the quote successfully' do
        expect(result.data).to be_a(Organization::Quote)
        expect(result.data.name).to eq("Updated Quote Name")
        expect(result.data.description).to eq("Updated description")
      end

      it 'creates a new version' do
        expect { result }
          .to change(Organization::ProjectVersion, :count).by(1)
          .and change(Organization::Item, :count).by(1)
      end
    end

    context 'when quote is posted' do
      before do
        quote.update!(posted: true, posted_at: Time.current)
      end

      it_behaves_like 'a failure', "Quote has already been posted or converted to a draft order"
    end

    context 'when quote has draft orders' do
      before do
        FactoryBot.create(:draft_order,
          company: company,
          client: client,
          original_project_version: quote_version
        )
      end

      it_behaves_like 'a failure', "Quote has already been posted or converted to a draft order"
    end

    context 'when update params are invalid' do
      let(:params) { { name: "" } }

      it_behaves_like 'a failure'
    end

    context 'with items' do
      let!(:existing_item) do
        FactoryBot.create(:item,
          project_version: quote_version,
          original_item_uuid: SecureRandom.uuid,
          name: "Original Item",
          description: "Original Description",
          unit: "days"
        )
      end

      let(:params) do
        {
          name: "Updated Quote Name",
          retention_guarantee_rate: 0.05,
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
        updated_quote = result.data
        new_version = updated_quote.versions.last
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
            name: "Updated Quote Name",
            retention_guarantee_rate: 0.05,
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
          name: "Updated Quote Name",
          retention_guarantee_rate: 0.05,
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
        updated_quote = result.data
        new_version = updated_quote.versions.last

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
            name: "Updated Quote Name",
            retention_guarantee_rate: 0.05,
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
            name: "Updated Quote Name",
            retention_guarantee_rate: 0.05,
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
