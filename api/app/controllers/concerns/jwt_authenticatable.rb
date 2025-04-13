module JwtAuthenticatable
  extend ActiveSupport::Concern

  def authenticate_user
    header = request.headers["Authorization"]
    token = header.split(" ").last if header
    authenticate_token(token)
  end

  def authenticate_token(token)
    begin
      decoded = JwtAuth.decode_access_token(token)
      @current_user = User.find(decoded["sub"])
    rescue JWT::ExpiredSignature
      skip_authorization
      raise Error::ForbiddenError, "Expired token"
    rescue JWT::DecodeError
      skip_authorization
      raise Error::ForbiddenError, "Invalid token"
    end
  end
end
