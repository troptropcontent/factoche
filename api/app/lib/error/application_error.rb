# frozen_string_literal: true

module Error
  # Base application error class
  # This is an abstract class and should never be raised directly.
  # Instead, use one of the specific error classes below or Custom for special cases.
  class ApplicationError < StandardError
    attr_reader :code, :status, :message

    def initialize(code, status, message)
      @code = code
      @status = status
      @message = message
      raise ArgumentError, "code, status and message must be present" unless [ code, status, message ].all?
    end
  end

  # 404 Not Found error
  # Raise this when a requested resource cannot be found in the database
  # Example: User tries to access a company that doesn't exist
  class NotFound < ApplicationError
    def initialize
      super(404, :not_found, "Resource not found")
    end
  end

  # 401 Unauthorized error
  # Raise this when authentication fails or is missing
  # Example: Invalid or expired JWT token, missing authentication headers
  class Unauthorized < ApplicationError
    def initialize
      super(401, :unauthorized, "Unauthorized access")
    end
  end

  # 403 Forbidden error
  # Raise this when a user is authenticated but doesn't have permission for the requested action
  # Example: Regular user trying to access admin-only endpoints
  class Forbidden < ApplicationError
    def initialize
      super(403, :forbidden, "Access forbidden")
    end
  end

  # 400 Bad Request error
  # Raise this when the request is malformed or contains invalid parameters
  # Example: Missing required parameters, invalid parameter format
  class BadRequest < ApplicationError
    def initialize
      super(400, :bad_request, "Invalid request")
    end
  end

  # 422 Unprocessable Entity error
  # Raise this when the request is well-formed but cannot be processed due to semantic errors
  # Example: Validation errors when creating/updating a resource
  class UnprocessableEntity < ApplicationError
    def initialize
      super(422, :unprocessable_entity, "Unprocessable entity")
    end
  end

  # 500 Internal Server Error
  # Raise this when an unexpected error occurs on the server
  # Example: Database connection failure, unexpected runtime errors
  class InternalServerError < ApplicationError
    def initialize
      super(500, :internal_server_error, "Internal server error")
    end
  end

  # 503 Service Unavailable error
  # Raise this when the service is temporarily unavailable
  # Example: Server is down for maintenance, third-party service is unavailable
  class ServiceUnavailable < ApplicationError
    def initialize
      super(503, :service_unavailable, "Service temporarily unavailable")
    end
  end

  # 409 Conflict error
  # Raise this when the request conflicts with the current state of the server
  # Example: Trying to create a resource that already exists, concurrent update conflicts
  class Conflict < ApplicationError
    def initialize
      super(409, :conflict, "Resource conflict")
    end
  end

  # Custom error for special cases
  # Use this when none of the standard error classes above fit your needs
  # Example: Custom business logic errors with specific status codes and messages
  class Custom < ApplicationError
    def initialize(code: 500, status: :unexpected, message: "An unexpected error occurred")
      super(code, status, message)
    end
  end
end
