require 'rails_helper'
# rubocop:disable RSpec/MultipleMemoizedHelpers
# rubocop:disable RSpec/ExampleLength

RSpec.describe Organization::UpdateCompletionSnapshot do
  describe '.call' do
    before { FactoryBot.create(:company_config, company: company) }

    let(:company) { FactoryBot.create(:company) }
    let(:client) { FactoryBot.create(:client, company: company) }
    let(:project) { FactoryBot.create(:project, client: client) }
    let(:project_version) { FactoryBot.create(:project_version, project: project) }
    let(:project_version_ungrouped_item) do
      FactoryBot.create(
        :item,
        project_version: project_version
      )
    end

    context "when the completion snapshot is not draft" do
      let!(:completion_snapshot) { instance_double(Organization::CompletionSnapshot, status: "published") }
      let(:update_dto) do
        Organization::CompletionSnapshots::UpdateDto.new({
          completion_snapshot_items: [
            {
              item_id: project_version_ungrouped_item.id,
              completion_percentage: "0.20"
            }
          ]
        })
      end

      it "raises an UnprocessableEntityError" do
        expect { described_class.call(update_dto, completion_snapshot) }
          .to raise_error(
            Error::UnprocessableEntityError,
            "Cannot update completion snapshot with status 'published'. Only snapshots in 'draft' status can be updated"
          )
      end
    end

    context "when the completion_snapshot_items does not belong to the project_version" do
      before { FactoryBot.create(:invoice, completion_snapshot: completion_snapshot) }

      let(:completion_snapshot) { FactoryBot.create(:completion_snapshot, project_version: project_version) }
      let(:another_project_version) { FactoryBot.create(:project_version, project: project) }
      let(:another_project_version_ungrouped_item) { FactoryBot.create(:item, project_version: another_project_version) }
      let(:update_dto) do
        Organization::CompletionSnapshots::UpdateDto.new({
          completion_snapshot_items: [
            {
              item_id: another_project_version_ungrouped_item.id,
              completion_percentage: "0.20"
            }
          ]
        })
      end

      it "raises an UnprocessableEntityError" do
        expect { described_class.call(update_dto, completion_snapshot) }
          .to raise_error(
            Error::UnprocessableEntityError,
            "The following item IDs do not belong to this completion snapshot project version: #{another_project_version_ungrouped_item.id}"
          )
      end
    end

    context "when the completion snapshot already has completion_snapshot_items" do
      let!(:completion_snapshot) do
        FactoryBot.create(
          :completion_snapshot,
          project_version: project_version,
          completion_snapshot_items_attributes: [
            {
              item_id: project_version_ungrouped_item.id,
              completion_percentage: "0.10"
            }
          ]
        )
      end
      let(:update_dto) do
        Organization::CompletionSnapshots::UpdateDto.new({
          completion_snapshot_items: [
            {
              item_id: project_version_ungrouped_item.id,
              completion_percentage: "0.30"
            }
          ]
        })
      end

      before { FactoryBot.create(:invoice, completion_snapshot: completion_snapshot) }


      it "deletes old completion_snapshot_items and recreates new ones" do
        expect { described_class.call(update_dto, completion_snapshot) }
          .to change { completion_snapshot.completion_snapshot_items.first.id }
      end

      it "updates the completion percentage" do
        described_class.call(update_dto, completion_snapshot)
        expect(completion_snapshot.reload.completion_snapshot_items.first.completion_percentage)
          .to eq(BigDecimal("0.30"))
      end

      it "maintains the correct number of items" do
        expect {
          described_class.call(update_dto, completion_snapshot)
        }.not_to change { completion_snapshot.completion_snapshot_items.count }
      end

      context "when updating multiple items" do
        let(:another_item) { FactoryBot.create(:item, project_version: project_version) }
        let!(:completion_snapshot) do
          FactoryBot.create(
            :completion_snapshot,
            project_version: project_version,
            completion_snapshot_items_attributes: [
              { item_id: project_version_ungrouped_item.id, completion_percentage: "0.10" },
              { item_id: another_item.id, completion_percentage: "0.20" }
            ]
          )
        end
        let(:update_dto) do
          Organization::CompletionSnapshots::UpdateDto.new({
            completion_snapshot_items: [
              {
                item_id: project_version_ungrouped_item.id,
                completion_percentage: "0.30"
              },
              {
                item_id: another_item.id,
                completion_percentage: "0.40"
              }
            ]
          })
        end

        it "updates all items correctly", :aggregate_failures do
          described_class.call(update_dto, completion_snapshot)
          completion_snapshot.reload

          expect(completion_snapshot.completion_snapshot_items.find_by(item_id: project_version_ungrouped_item.id).completion_percentage)
            .to eq(BigDecimal("0.30"))
          expect(completion_snapshot.completion_snapshot_items.find_by(item_id: another_item.id).completion_percentage)
            .to eq(BigDecimal("0.40"))
        end
      end
    end

    it "update the attached invoice" do
      completion_snapshot = FactoryBot.create(
        :completion_snapshot,
        project_version: project_version,
        completion_snapshot_items_attributes: [
          {
            item_id: project_version_ungrouped_item.id,
            completion_percentage: "0.10"
          }
        ]
      )
      invoice = FactoryBot.create(:invoice, completion_snapshot: completion_snapshot)
      update_dto = Organization::CompletionSnapshots::UpdateDto.new({
        completion_snapshot_items: [
          {
            item_id: project_version_ungrouped_item.id,
            completion_percentage: "0.40"
          }
        ]
      })

      expect { described_class.call(update_dto, completion_snapshot) }.to change { invoice.reload.updated_at }
    end

    it "returns the updated completion_snapshot" do
      completion_snapshot = FactoryBot.create(
        :completion_snapshot,
        project_version: project_version,
        completion_snapshot_items_attributes: [
          {
            item_id: project_version_ungrouped_item.id,
            completion_percentage: "0.10"
          }
        ]
      )
      FactoryBot.create(:invoice, completion_snapshot: completion_snapshot)
      update_dto = Organization::CompletionSnapshots::UpdateDto.new({
        completion_snapshot_items: [
          {
            item_id: project_version_ungrouped_item.id,
            completion_percentage: "0.40"
          }
        ]
      })
      expect(described_class.call(update_dto, completion_snapshot).completion_snapshot_items.first.completion_percentage)
        .to eq(BigDecimal("0.40"))
    end
  end
end
