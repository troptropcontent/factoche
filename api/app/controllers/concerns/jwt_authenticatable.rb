module JwtAuthenticatable
  extend ActiveSupport::Concern

  def authenticate_user
    header = request.headers["Authorization"]
    token = header.split(" ").last if header
    begin
      decoded = JwtAuth.decode_access_token(token)
      @current_user = User.find(decoded["sub"])
    rescue JWT::ExpiredSignature
      render json: { error: "Token has expired" }, status: :unauthorized
    rescue JWT::DecodeError
      render json: { error: "Invalid token" }, status: :unauthorized
    end
  end
end
