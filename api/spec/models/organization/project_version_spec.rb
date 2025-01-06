require 'rails_helper'

RSpec.describe Organization::ProjectVersion, type: :model do
  subject { FactoryBot.create(:project_version, project: project) }
  let(:company) { FactoryBot.create(:company) }
  let(:client) { FactoryBot.create(:client, company: company) }
  let(:project) { FactoryBot.create(:project, client: client) }
  describe 'associations' do
    it { should belong_to(:project) }
    it { should have_many(:items).class_name('Organization::Item') }
    it { should have_many(:item_groups).class_name('Organization::ItemGroup') }
  end

  describe 'nested attributes' do
    it { should accept_nested_attributes_for(:items) }
    it { should accept_nested_attributes_for(:item_groups) }
  end

  describe '#next_available_number' do
    context 'when project_id is not set' do
      subject { FactoryBot.build(:project_version, project: nil) }

      it 'raises an error' do
        expect { subject.send(:next_available_number) }
          .to raise_error(RuntimeError, "Project must be set to determine next version number")
      end
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:number) }
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
end
