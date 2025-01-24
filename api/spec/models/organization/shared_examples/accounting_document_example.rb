RSpec.shared_examples "an accounting document" do |parameter|
  describe 'associations' do
    it { is_expected.to belong_to(:completion_snapshot).class_name('Organization::CompletionSnapshot') }
    it { is_expected.to have_one(:pdf_attachment) }
    it { is_expected.to have_one(:xml_attachment) }
  end

  describe 'validation' do
    it { is_expected.to validate_numericality_of(:total_amount_cents).is_greater_than_or_equal_to(0) }
  end
end
