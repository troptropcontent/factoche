require 'rails_helper'

RSpec.describe Organization::CompanyConfig, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:company) }
  end
end
