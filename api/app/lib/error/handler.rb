# frozen_string_literal: true

module Error
  # Handles error responses for controllers
  module Handler
    def self.included(clazz)
      clazz.class_eval do
        rescue_from StandardError do |e|
          request.format = :json
          render json: {
            error: {
              status: :unexpected,
              code: 500,
              message: e.to_s,
              details: nil
            }
          }, status: :unexpected
        end

        rescue_from ApplicationError do |e|
          request.format = :json
          render json: {
            error: {
              status: e.class.status,
              code: e.class.code,
              message: e.message || e.class.message,
              details: e.respond_to?(:details) ? e.details : nil
            }
          }, status: e.class.status
        end

        rescue_from Pundit::NotAuthorizedError do |e|
          request.format = :json
          render json: {
            error: {
              status: Error::ForbiddenError.status,
              code: Error::ForbiddenError.code,
              message: Error::ForbiddenError.message,
              details: nil
            }
          }, status: Error::ForbiddenError.status
        end

        rescue_from ActiveRecord::RecordNotFound do |e|
          request.format = :json
          render json: {
            error: {
              status: Error::NotFoundError.status,
              code: Error::NotFoundError.code,
              message: Error::NotFoundError.message,
              details: nil
            }
          }, status: Error::NotFoundError.status
        end

        rescue_from ActiveRecord::RecordInvalid do |e|
          request.format = :json
          render json: {
            error: {
              status: UnprocessableEntityError.status,
              code: UnprocessableEntityError.code,
              message: UnprocessableEntityError.message,
              details: e.record.errors.group_by_attribute.transform_values do |errors|
                errors.map do |error|
                  {
                    type: error.type,
                    message: error.message,
                    options: error.options,
                    details: error.details
                  }
                end
              end
            }
          }, status: UnprocessableEntityError.status
        end
      end
    end
  end
end
