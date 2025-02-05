module Error
  # 409 Conflict error
  # Raise this when the request conflicts with the current state of the server
  # Example: Trying to create a resource that already exists, concurrent update conflicts
  class ConflictError < ApplicationError
    code 409
    status :conflict
    message "Resource conflict"
  end
end
