module Error
  # 503 Service Unavailable error
  # Raise this when the service is temporarily unavailable
  # Example: Server is down for maintenance, third-party service is unavailable
  class ServiceUnavailableError < ApplicationError
    code 503
    status :service_unavailable
    message "Service temporarily unavailable"
  end
end
