require 'rails_helper'

RSpec.describe Organization::ProjectVersion, type: :model do
  subject(:project_version) { FactoryBot.create(:project_version, project: project) }

  let(:company) { FactoryBot.create(:company) }
  let(:client) { FactoryBot.create(:client, company: company) }
  let(:project) { FactoryBot.create(:quote, client: client) }

  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to have_many(:items).class_name('Organization::Item') }
    it { is_expected.to have_many(:item_groups).class_name('Organization::ItemGroup') }
    it { is_expected.to have_many(:ungrouped_items).class_name('Organization::Item') }
  end

  describe 'nested attributes' do
    it { is_expected.to accept_nested_attributes_for(:item_groups) }
  end

  describe '#next_available_number' do
    context 'when project_id is not set' do
      subject(:project_version) { FactoryBot.build(:project_version, project: nil) }

      it 'raises an error' do
        expect { project_version.send(:next_available_number) }
          .to raise_error(RuntimeError, "Project must be set to determine next version number")
      end
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:number) }
    it { is_expected.to validate_presence_of(:retention_guarantee_rate) }

    it { expect(project_version).to validate_numericality_of(:retention_guarantee_rate)
          .is_greater_than_or_equal_to(0)
          .is_less_than_or_equal_to(1) }
    # Uniqueness validation of number scoped to project_id is not necessary
    # since we automatically set the number to the next available number
    # through the before_validation callback on create
    # it { should validate_uniqueness_of(:number).scoped_to(:project_id) }
  end

  describe 'callbacks' do
    describe 'before_validation on create' do
      context 'when creating a new version' do
        context 'when there are no existing versions' do
          it 'sets number to 1' do
            version = FactoryBot.build(:project_version, project: project)
            version.valid?
            expect(version.number).to eq(1)
          end
        end

        context 'when there are existing versions' do
          before do
            FactoryBot.create(:project_version, project: project)
          end

          it 'sets number to the next available number' do
            version = FactoryBot.build(:project_version, project: project)
            version.valid?
            expect(version.number).to eq(2)
          end
        end

        context 'when number set directly' do
          before do
            FactoryBot.create(:project_version, project: project)
          end

          it 'overwrites the number set' do
            version = FactoryBot.build(:project_version, project: project, number: 10)
            version.valid?
            expect(version.number).to eq(2)
          end
        end
      end

      context 'when updating an existing version' do
        let(:version) { FactoryBot.create(:project_version, project: project) }

        it 'does not change the number' do
          expect {
            version.update(project: project)
          }.not_to change(version, :number)
        end
      end
    end
  end

  describe 'scopes' do
    describe ".lasts" do
      before {
        FactoryBot.create(:project_version, project: project)
        FactoryBot.create(:project_version, project: project)
        another_project = FactoryBot.create(:quote, client: client, name: "AnotherProject")
        FactoryBot.create(:project_version, project: another_project)
        FactoryBot.create(:project_version, project: another_project)
        FactoryBot.create(:project_version, project: another_project)
      }

      it "only returns the last project versions", :aggregate_failures do
        expect(described_class.lasts.count).to eq(2)
        expect(described_class.lasts.find_by(project_id: project.id).number).to eq(2)
        expect(described_class.lasts.joins(:project).find_by({ project: { name: "AnotherProject" } }).number).to eq(3)
      end
    end
  end

  describe "instance methods" do
    describe "#is_last_versions?" do
      before {
        FactoryBot.create(:project_version, project: project)
        FactoryBot.create(:project_version, project: project)
      }

      context "when the record is the last version" do
        it "returns true" do
          record = described_class.find_by({ number: 2 })
          expect(record.is_last_version?).to be(true)
        end
      end

      context "when the record is the not the last version" do
        it "returns true" do
          record = described_class.find_by({ number: 1 })
          expect(record.is_last_version?).to be(false)
        end
      end
    end
  end
end
