RSpec.shared_examples "an authenticated endpoint" do |parameter|
  response "403", "forbiden" do
    describe "when the token is not there" do
      let(:Authorization) { "" }

      run_test!
    end

    describe "when the token is not valid" do
      let(:Authorization) { "q" }

      run_test!
    end

    describe "when the token is expired" do
      let(:Authorization) {
        travel_to(3.day.before) { "Bearer #{JwtAuth.generate_access_token(user.id)}"  }
      }

      run_test!
    end
  end
end
