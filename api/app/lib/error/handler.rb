# frozen_string_literal: true

module Error
  # Handles error responses for controllers
  module Handler
    def self.included(clazz)
      clazz.class_eval do
        rescue_from StandardError do |e|
          render json: {
            error: {
              status: :unexpected,
              code: 500,
              message: e.to_s
            }
          }, status: :unexpected
        end

        rescue_from ApplicationError do |e|
          render json: {
            error: {
              status: e.class.status,
              code: e.class.code,
              message: e.class.message
            }
          }, status: e.class.status
        end

        rescue_from Pundit::NotAuthorizedError do
          render json: {
            error: {
              status: Error::ForbiddenError.status,
              code: Error::ForbiddenError.code,
              message: Error::ForbiddenError.message
            }
          }, status: Error::ForbiddenError.status
        end

        rescue_from ActiveRecord::RecordNotFound do
          render json: {
            error: {
              status: Error::NotFoundError.status,
              code: Error::NotFoundError.code,
              message: Error::NotFoundError.message
            }
          }, status: Error::NotFoundError.status
        end
      end
    end
  end
end
