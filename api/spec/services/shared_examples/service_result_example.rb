RSpec.shared_examples "a success" do
  it { is_expected.to be_success }
end

RSpec.shared_examples "a failure" do |message|
  it { is_expected.to be_failure }

  if message
    it {
      expect(subject.error.message).to include(message)
    }
  end
end
