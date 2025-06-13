require_relative "production"

Rails.application.configure do
  config.action_cable.allowed_request_origins = [ "https://app.staging.fabati.fr" ]
end
