class Api::V1::ApiV1Controller < ApplicationController
  include Error::Handler
  include JwtAuthenticatable
  include Pundit::Authorization

  before_action :authenticate_user

  private

  def current_user
    @current_user
  end

  def load_and_authorise_resource(name: nil, class_name: nil, param_key: nil)
    id = params[param_key || "id"]
    klass = (class_name || detect_resource_class).constantize
    instance_variable_name = name || klass.name.demodulize.underscore
    instance_variable_set("@#{instance_variable_name}", klass.find(id))

    raise Error::UnauthorizedError unless policy_scope(klass).exists?({ id: id })
  end

  def detect_resource_class
    regexp = /Api::V1::(?<modules>.*)::(?<controller>.*)Controller/

    r = self.class.name.match(regexp)

    [ r[:modules], r[:controller].singularize ].join("::")
  end
end
