require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:members).dependent(:destroy) }
    it { should have_many(:companies).through(:members) }
  end
end
