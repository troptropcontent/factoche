class Api::V1::ApiV1Controller < ApplicationController
  include Error::Handler
  include JwtAuthenticatable
  include Pundit::Authorization

  before_action :authenticate_user

  private

  def current_user
    @current_user
  end
end
