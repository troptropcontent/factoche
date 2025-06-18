module JwtAuth
  ACCESS_TOKEN_EXPIRATION_TIME = 24.hours
  REFRESH_TOKEN_EXPIRATION_TIME = 30.days
  TOKEN_REGEXP = /Bearer (.+)/

  # This method is used to decode a token
  # It returns the payload of the token or fails
  def self.decode_token(token, secret)
    JWT.decode(token, secret, true)[0]
  end

  # This method is used to decode the access token
  # It returns the payload of the token wich is a hash with the following keys:
  # - sub: the subject of the token (the user id)
  # - iat: the issued at time
  # - exp: the expiration time
  # - jti: the jwt id
  def self.decode_access_token(token)
    decode_token(token, ENV.fetch("ACCESS_TOKEN_SECRET"))
  end

  # This method is used to decode the refresh token
  # It returns the payload of the token wich is a hash with the following keys:
  # - sub: the subject of the token (the user id)
  # - iat: the issued at time
  # - exp: the expiration time
  # - jti: the jwt id
  def self.decode_refresh_token(token)
    decode_token(token, ENV.fetch("REFRESH_TOKEN_SECRET"))
  end

  # This method is used to generate a token
  # It returns the token as a string
  def self.generate_token(resource_id, secret, exp)
    payload = {
      sub: resource_id.to_s,
      iat: Time.now.to_i,
      exp: exp.from_now.to_i,
      jti: SecureRandom.uuid
    }
    JWT.encode(
      payload,
      secret
    )
  end

  # This method is used to generate the access token
  # It returns the token as a string
  def self.generate_access_token(user_id)
    generate_token(user_id, ENV.fetch("ACCESS_TOKEN_SECRET"), ACCESS_TOKEN_EXPIRATION_TIME)
  end

  # This method is used to generate the refresh token
  # It returns the token as a string
  def self.generate_refresh_token(user_id)
    generate_token(user_id, ENV.fetch("REFRESH_TOKEN_SECRET"), REFRESH_TOKEN_EXPIRATION_TIME)
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
