module Error
  # 403 Forbidden error
  # Raise this when the user is authenticated but doesn't have permission to access the resource
  # Example: Attempting to access admin-only features as a regular user
  class ForbiddenError < ApplicationError
    code 403
    status :forbidden
    message "Access forbidden"
  end
end
