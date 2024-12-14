class Api::V1::Auth::SessionsController < ApplicationController
  skip_before_action :authenticate_user, only: [ :create, :refresh ]

  # POST /api/v1/auth/login
  # Create a new session for a user
  # It returns the access and refresh tokens if the credentials are valid
  # It returns an error if the credentials are invalid
  def create
    user = User.find_by(email: session_params[:email])
    if user && user.authenticate(session_params[:password])
      render json: { access_token: JwtAuth.generate_access_token(user.id), refresh_token: JwtAuth.generate_refresh_token(user.id) }
    else
      render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  end

  # POST /api/v1/auth/refresh
  # Refresh the access token
  def refresh
    token = JwtAuth.find_token(request)

    begin
      claims = JwtAuth.decode_refresh_token(token)
      render json: { access_token: JwtAuth.generate_access_token(claims["sub"]) }
    rescue JWT::ExpiredSignature
      render json: { error: "Token has expired" }, status: :unauthorized
    rescue JWT::DecodeError
      render json: { error: "Invalid token" }, status: :unauthorized
    end
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
