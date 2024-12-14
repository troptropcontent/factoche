class Api::V1::Auth::SessionsController < ApplicationController
  skip_before_action :authenticate_user, only: [ :create ]

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

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
