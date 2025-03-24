module Error
  # 422 Unprocessable Entity error
  # Raise this when the request is well-formed but cannot be processed due to semantic errors
  # Example: Validation errors when creating/updating a resource
  class UnprocessableEntityError < ApplicationError
    code 422
    status :unprocessable_entity
    message "Unprocessable entity"
  end
end
