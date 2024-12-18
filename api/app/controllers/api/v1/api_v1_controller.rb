class Api::V1::ApiV1Controller < ApplicationController
  include Error::Handler
  include JwtAuthenticatable
  include Pundit::Authorization

  before_action :authenticate_user

  private

  def check_pundit_authorization_performed!
    authorization_performed = pundit_policy_authorized? || pundit_policy_scoped?

    raise Error::Custom.new(message: "Unauthorized endpoint") unless authorization_performed
  end

  def current_user
    @current_user
  end

  def render(*args)
    check_pundit_authorization_performed!
    skip_authorization
    super(*args)
  end
end
