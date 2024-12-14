module JwtAuth
  ACCESS_TOKEN_EXPIRATION_TIME = 24.hours
  REFRESH_TOKEN_EXPIRATION_TIME = 30.days
  def self.generate_access_token(user_id)
    payload = {
      sub: user_id.to_s,
      iat: Time.now.to_i,
      exp: ACCESS_TOKEN_EXPIRATION_TIME.from_now.to_i,
      jti: SecureRandom.uuid
    }
    JWT.encode(
      payload,
      Rails.application.credentials.token_secrets.access
    )
  end

  def self.generate_refresh_token(user_id)
    payload = {
      sub: user_id.to_s,
      iat: Time.now.to_i,
      exp: REFRESH_TOKEN_EXPIRATION_TIME.from_now.to_i,
      jti: SecureRandom.uuid
    }
    JWT.encode(
      payload,
      Rails.application.credentials.token_secrets.refresh
    )
  end
end
