require 'rails_helper'

RSpec.describe Organization::Member, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:company).class_name("Organization::Company") }
  end

  describe "validations" do
    subject { FactoryBot.build(:member) }
    before {
      user = FactoryBot.create(:user)
      company = FactoryBot.create(:company)
      FactoryBot.create(:member, user: user, company: company)
    }
    it { should validate_uniqueness_of(:user_id).scoped_to(:company_id) }
  end
end
