require 'rails_helper'

RSpec.describe Organization::Project, type: :model, focus: true do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    describe("unique name within client scope") do
      let(:company) { FactoryBot.create(:company) }
      let(:client) { FactoryBot.create(:client, company:) }
      let(:taken_name) { "taken_name" }
      let(:already_existing_project) { FactoryBot.create(:project, client:, name: taken_name) }
      subject { FactoryBot.build(:project, name: taken_name, client:) }
      it { should validate_uniqueness_of(:name).scoped_to(:client_id) }
    end

    it { should validate_presence_of(:retention_guarantee_rate) }
    it { should validate_numericality_of(:retention_guarantee_rate)
          .is_greater_than_or_equal_to(0)
          .is_less_than_or_equal_to(100) }
  end
end
