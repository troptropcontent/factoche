require 'rails_helper'

RSpec.describe Organization::UpdateCompletionSnapshot do
  describe '.call' do
    let(:company) { FactoryBot.create(:company) }
    let(:client) { FactoryBot.create(:client, company: company) }
    let(:project) { FactoryBot.create(:project, client: client) }
    let(:project_version) { FactoryBot.create(:project_version, project: project) }
    let(:project_version_ungrouped_item) do
      FactoryBot.create(
        :item,
        project_version: project_version,
      )
    end

    context "when the completion snapshot is not draft" do
      let!(:completion_snapshot) { instance_double(Organization::CompletionSnapshot, status: "invoiced") }
      let(:update_dto) do
        Organization::CompletionSnapshots::UpdateDto.new({
          completion_snapshot_items: [
            {
              item_id: project_version_ungrouped_item.id,
              completion_percentage: "20"
            }
          ]
        })
      end

      it "raises an UnprocessableEntityError" do
        expect { described_class.call(update_dto, completion_snapshot) }.to raise_error(Error::UnprocessableEntityError, "Cannot update completion snapshot with status 'invoiced'. Only snapshots in 'draft' status can be updated")
      end
    end

    context "when the completion_snapshot_items does not belong to the project_version" do
      let(:completion_snapshot) { FactoryBot.create(:completion_snapshot, project_version: project_version) }
      let(:another_project_version) { FactoryBot.create(:project_version, project: project) }
      let(:another_project_version_ungrouped_item) { FactoryBot.create(:item, project_version: another_project_version) }
      let(:update_dto) do
        Organization::CompletionSnapshots::UpdateDto.new({
          completion_snapshot_items: [
            {
              item_id: another_project_version_ungrouped_item.id,
              completion_percentage: "20"
            }
          ]
        })
      end

      it "raises an UnprocessableEntityError" do
        expect { described_class.call(update_dto, completion_snapshot) }.to raise_error(Error::UnprocessableEntityError, "The following item IDs do not belong to this completion snapshot project version: #{another_project_version_ungrouped_item.id}")
      end
    end

    context "when the completion snapshot already has completion_snapshot_items" do
      let!(:completion_snapshot) { FactoryBot.create(:completion_snapshot, project_version: project_version, completion_snapshot_items_attributes: [ { item_id: project_version_ungrouped_item.id, completion_percentage: "10" } ]) }
      let(:update_dto) do
        Organization::CompletionSnapshots::UpdateDto.new({
          completion_snapshot_items: [
            {
              item_id: project_version_ungrouped_item.id,
              completion_percentage: "30"
            }
          ]
        })
      end

      it "deletes old completion_snapshot_items and recreates new ones" do
        expect { described_class.call(update_dto, completion_snapshot) }.to change { completion_snapshot.completion_snapshot_items.first.id }
      end

      it "updates the completion percentage" do
        described_class.call(update_dto, completion_snapshot)
        expect(completion_snapshot.reload.completion_snapshot_items.first.completion_percentage).to eq(BigDecimal("30"))
      end

      it "maintains the correct number of items" do
        expect {
          described_class.call(update_dto, completion_snapshot)
        }.not_to change { completion_snapshot.completion_snapshot_items.count }
      end

      context "when updating multiple items" do
        let(:another_item) { FactoryBot.create(:item, project_version: project_version) }
        let!(:completion_snapshot) do
          FactoryBot.create(:completion_snapshot,
            project_version: project_version,
            completion_snapshot_items_attributes: [
              { item_id: project_version_ungrouped_item.id, completion_percentage: "10" },
              { item_id: another_item.id, completion_percentage: "20" }
            ]
          )
        end
        let(:update_dto) do
          Organization::CompletionSnapshots::UpdateDto.new({
            completion_snapshot_items: [
              {
                item_id: project_version_ungrouped_item.id,
                completion_percentage: "30"
              },
              {
                item_id: another_item.id,
                completion_percentage: "40"
              }
            ]
          })
        end

        it "updates all items correctly", :aggregate_failures do
          described_class.call(update_dto, completion_snapshot)
          completion_snapshot.reload

          expect(completion_snapshot.completion_snapshot_items.find_by(item_id: project_version_ungrouped_item.id).completion_percentage).to eq(BigDecimal("30"))
          expect(completion_snapshot.completion_snapshot_items.find_by(item_id: another_item.id).completion_percentage).to eq(BigDecimal("40"))
        end
      end
    end

    it "returns the updated completion_snapshot" do
      completion_snapshot = FactoryBot.create(:completion_snapshot, project_version: project_version, completion_snapshot_items_attributes: [ { item_id: project_version_ungrouped_item.id, completion_percentage: "10" } ])
      update_dto = Organization::CompletionSnapshots::UpdateDto.new({
        completion_snapshot_items: [
          {
            item_id: project_version_ungrouped_item.id,
            completion_percentage: "40"
          }
        ]
      })
      expect(described_class.call(update_dto, completion_snapshot).completion_snapshot_items.first.completion_percentage).to eq(BigDecimal("40"))
    end
  end
end
