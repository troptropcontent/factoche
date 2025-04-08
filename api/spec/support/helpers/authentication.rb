module Helpers
  module Authentication
    def access_token(user)
      "Bearer #{JwtAuth.generate_access_token(user.id)}"
    end
  end
end
