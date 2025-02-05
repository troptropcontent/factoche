module Error
  # 400 Bad Request error
  # Raise this when the request is malformed or contains invalid parameters
  # Example: Missing required parameters, invalid parameter format
  class BadRequestError < ApplicationError
    code 400
    status :bad_request
    message "Invalid request"
  end
end
