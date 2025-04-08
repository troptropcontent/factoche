require 'rails_helper'
require 'services/shared_examples/service_result_example'

module Organization
  module Projects
    RSpec.describe Duplicate, type: :service do
      define_negated_matcher :not_change, :change
      describe '#call', :aggregate_failures do
      let(:company) { FactoryBot.create(:company) }
      let(:client) { FactoryBot.create(:client, company:) }

      subject(:result) { described_class.call(original_project, new_project_class) }

      [
       {
        original_project_class: Organization::Quote,
        new_project_class: Organization::DraftOrder
       },
       {
        original_project_class: Organization::DraftOrder,
        new_project_class: Organization::Order
       }
      ].each do |scenario|
        context "when the original project is a #{scenario[:original_project_class].name} and the new project class is a #{scenario[:new_project_class].name}" do
            let(:new_project_class) { scenario[:new_project_class] }
            let(:original_project) { FactoryBot.create(:project, company: company, client: client, type: scenario[:original_project_class].name) }
            let(:original_project_version) { FactoryBot.create(:project_version, project: original_project) }

            context "when the project have groups" do
              let(:original_project_version_group) { FactoryBot.create(:item_group, project_version: original_project_version) }
              let!(:original_project_version_item) { FactoryBot.create(:item, project_version: original_project_version, item_group: original_project_version_group) }

              it_behaves_like 'a success'

              it "creates a new #{scenario[:new_project_class].name}, a new ProjectVersion, n ItemGroup and n Item" do
                expect {
                  result
                }.to change(scenario[:new_project_class], :count).by(1)
                 .and change(ProjectVersion, :count).by(1)
                 .and change(Item, :count).by(1)
                 .and change(ItemGroup, :count).by(1)
              end

              it "copies the attributes of the original project into the new_project" do
                new_project = result.data[:new_project]
                expect(new_project).to be_a(scenario[:new_project_class])
                expect(new_project).to have_attributes(original_project.attributes.except(
                 "id", "type", "created_at", "updated_at", "original_project_version_id"
                ))
             end

             it "copies the attributes of the original project version into the new_project version" do
               new_project_version = result.data[:new_project_version]
                expect(new_project_version).to have_attributes(original_project_version.attributes.except(
                  "id", "project_id", "created_at", "updated_at"
                ))
              end

              it "copies the attributes of the original project item groups into the new_project item groups" do
                new_item_group = result.data[:new_project_version].item_groups.first
                expect(new_item_group).to have_attributes(original_project_version_group.attributes.except(
                  "id", "project_version_id", "created_at", "updated_at"
                ))
              end

              it "copies the attributes of the original project items into the new_project items" do
                 new_item = result.data[:new_project_version].items.first
                 expect(new_item).to have_attributes(original_project_version_item.attributes.except(
                  "id", "project_version_id", "item_group_id", "created_at", "updated_at", "original_item_uuid"
                ))
                expect(new_item.original_item_uuid).not_to eq(original_project_version_item.original_item_uuid)
              end
            end

            context "when the project have standalone items" do
              let!(:original_project_version_item) { FactoryBot.create(:item, project_version: original_project_version) }

              it_behaves_like 'a success'

              it "creates a new #{scenario[:new_project_class].name}, a new ProjectVersion and n Item" do
                expect {
                  result
                }.to change(scenario[:new_project_class], :count).by(1)
                 .and change(ProjectVersion, :count).by(1)
                 .and change(Item, :count).by(1)
                 .and not_change(ItemGroup, :count)
              end

              it "copies the attributes of the original project into the new_project" do
                new_project = result.data[:new_project]
                expect(new_project).to be_a(scenario[:new_project_class])
                expect(new_project).to have_attributes(original_project.attributes.except(
                 "id", "type", "created_at", "updated_at", "original_project_version_id"
                ))
             end

             it "copies the attributes of the original project version into the new_project version" do
               new_project_version = result.data[:new_project_version]
                expect(new_project_version).to have_attributes(original_project_version.attributes.except(
                  "id", "project_id", "created_at", "updated_at"
                ))
              end

              it "copies the attributes of the original project items into the new_project items" do
                 new_item = result.data[:new_project_version].items.first
                 expect(new_item).to have_attributes(original_project_version_item.attributes.except(
                  "id", "project_version_id", "item_group_id", "created_at", "updated_at", "original_item_uuid"
                ))
                expect(new_item.original_item_uuid).not_to eq(original_project_version_item.original_item_uuid)
              end
            end

            context "when the project has no version" do
              it_behaves_like 'a failure', "Original project has no version recorded, it's likely a bug"
            end

            context "when the new project class is not a descendant of Project" do
              let(:new_project_class) { String }

              before { original_project_version }

              it_behaves_like 'a failure', "The new project class must be a descendant of Project"
            end
          end
        end
      end
    end
  end
end
