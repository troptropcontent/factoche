module Error
  # 500 Internal Server Error
  # Raise this when an unexpected error occurs on the server
  # Example: Database connection failure, unexpected runtime errors
  class InternalServerError < ApplicationError
    code 500
    status :internal_server_error
    message "Internal server error"
  end
end
