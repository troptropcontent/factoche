module Error
  # 404 Not Found error
  # Raise this when the requested resource does not exist
  # Example: Attempting to access a record that has been deleted or never existed
  class NotFoundError < ApplicationError
    code 404
    status :not_found
    message "Resource not found"
  end
end
