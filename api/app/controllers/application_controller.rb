class ApplicationController < ActionController::API
  include JwtAuthenticatable

  before_action :authenticate_user

  private

  def current_user
    @current_user
  end
end
