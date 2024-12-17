module JwtAuthenticatable
  extend ActiveSupport::Concern

  def authenticate_user
    header = request.headers["Authorization"]
    token = header.split(" ").last if header
    begin
      decoded = JwtAuth.decode_access_token(token)
      @current_user = User.find(decoded["sub"])
    rescue JWT::ExpiredSignature
      skip_authorization
      raise Error::Custom.new(code: 401, status: :unauthorized, message: "Expired token")
    rescue JWT::DecodeError
      skip_authorization
      raise Error::Custom.new(code: 401, status: :unauthorized, message: "Invalid token")
    end
  end
end
