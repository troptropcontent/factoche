module Error
  # 401 Unauthorized error
  # Raise this when authentication is required but not provided or is invalid
  # Example: Missing authentication token, invalid credentials
  class UnauthorizedError < ApplicationError
    code 401
    status :unauthorized
    message "Unauthorized resource"
  end
end
