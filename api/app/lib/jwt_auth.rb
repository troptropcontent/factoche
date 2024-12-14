module JwtAuth
  ACCESS_TOKEN_EXPIRATION_TIME = 24.hours
  REFRESH_TOKEN_EXPIRATION_TIME = 30.days
  TOKEN_REGEXP = /Bearer (.+)/

  # This method is used to decode the access token
  # It returns the payload of the token wich is a hash with the following keys:
  # - sub: the subject of the token (the user id)
  # - iat: the issued at time
  # - exp: the expiration time
  # - jti: the jwt id
  def self.decode_access_token(token)
    JWT.decode(token, Rails.application.credentials.token_secrets.access, true)[0]
  end

  # This method is used to decode the refresh token
  # It returns the payload of the token wich is a hash with the following keys:
  # - sub: the subject of the token (the user id)
  # - iat: the issued at time
  # - exp: the expiration time
  # - jti: the jwt id
  def self.decode_refresh_token(token)
    JWT.decode(token, Rails.application.credentials.token_secrets.refresh, true)[0]
  end

  # This method is used to generate the access token
  # It returns the token as a string
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

  # This method is used to generate the refresh token
  # It returns the token as a string
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

  # This method is used to find the token in the request headers
  # It returns the token as a string
  # It returns nil if the token is not found or invalid
  def self.find_token(request)
    header = request.headers["Authorization"]
    return nil unless header && header.match(TOKEN_REGEXP)
    header.match(TOKEN_REGEXP)[1]
  end
end
