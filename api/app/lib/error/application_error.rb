module Error
  # Base module for defining error attributes
  module ErrorAttributes
    def code(value = nil)
      return @code unless value
      @code = value
    end

    def message(value = nil)
      return @message unless value
      @message = value
    end

    def status(value = nil)
      return @status unless value
      @status = value
    end
  end

  # Base class for all application errors
  class ApplicationError < StandardError
    extend ErrorAttributes
  end

  # 401 Unauthorized error
  # Raise this when authentication is required but not provided or is invalid
  # Example: Missing authentication token, invalid credentials
  class UnauthorizedError < ApplicationError
    code 401
    status :unauthorized
    message "Unauthorized resource"
  end

  # 404 Not Found error
  # Raise this when the requested resource does not exist
  # Example: Attempting to access a record that has been deleted or never existed
  class NotFoundError < ApplicationError
    code 404
    status :not_found
    message "Resource not found"
  end

  # 403 Forbidden error
  # Raise this when the user is authenticated but doesn't have permission to access the resource
  # Example: Attempting to access admin-only features as a regular user
  class ForbiddenError < ApplicationError
    code 403
    status :forbidden
    message "Access forbidden"
  end

  # 400 Bad Request error
  # Raise this when the request is malformed or contains invalid parameters
  # Example: Missing required parameters, invalid parameter format
  class BadRequestError < ApplicationError
    code 400
    status :bad_request
    message "Invalid request"
  end

  # 422 Unprocessable Entity error
  # Raise this when the request is well-formed but cannot be processed due to semantic errors
  # Example: Validation errors when creating/updating a resource
  class UnprocessableEntityError < ApplicationError
    code 422
    status :unprocessable_entity
    message "Unprocessable entity"
  end

  # 500 Internal Server Error
  # Raise this when an unexpected error occurs on the server
  # Example: Database connection failure, unexpected runtime errors
  class InternalServerError < ApplicationError
    code 500
    status :internal_server_error
    message "Internal server error"
  end

  # 503 Service Unavailable error
  # Raise this when the service is temporarily unavailable
  # Example: Server is down for maintenance, third-party service is unavailable
  class ServiceUnavailableError < ApplicationError
    code 503
    status :service_unavailable
    message "Service temporarily unavailable"
  end

  # 409 Conflict error
  # Raise this when the request conflicts with the current state of the server
  # Example: Trying to create a resource that already exists, concurrent update conflicts
  class ConflictError < ApplicationError
    code 409
    status :conflict
    message "Resource conflict"
  end
end
