class ApplicationController < ActionController::API
  include JwtAuthenticatable

  before_action :authenticate_user
end
