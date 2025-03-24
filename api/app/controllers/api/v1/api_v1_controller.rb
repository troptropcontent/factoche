class Api::V1::ApiV1Controller < ApplicationController
  include Error::Handler
  include JwtAuthenticatable
  include Pundit::Authorization

  before_action :authenticate_user

  private

  def current_user
    @current_user
  end

  def load_and_authorise_resource(name, class_name: nil, param_key: nil)
    id = params[param_key || "#{name}_id"]
    klass = (class_name || name.camelize).constantize
    instance_variable_set("@#{name}", klass.find(id))

    raise Error::UnauthorizedError unless policy_scope(klass).exists?({ id: id })
  end
end
