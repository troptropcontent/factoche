# rubocop:disable RSpec/ContextWording
# rubocop:disable RSpec/LetSetup
RSpec.shared_context 'a company with a client and a member' do
  let(:user) { FactoryBot.create(:user) }
  let!(:member) { FactoryBot.create(:member, user:, company:) }
  let(:company) { FactoryBot.create(:company, :with_config, :with_bank_detail) }
  let!(:client) { FactoryBot.create(:client, company: company) }
end
# rubocop:enable RSpec/ContextWording
# rubocop:enable RSpec/LetSetup
