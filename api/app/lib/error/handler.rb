# frozen_string_literal: true

module Error
  # Handles error responses for controllers
  module Handler
    include ActionController::MimeResponds
    def self.included(clazz)
      clazz.class_eval do
        private

        def render_application_error(error:, status:, code:, message:, details: nil)
          respond_to do |format|
            format.html do
              render "errors/error", locals: { error: error, status: status, code: code, message: message, details: details }, status: status
            end
            format.json do
              render json: {
                error: {
                  status: status,
                  code: code,
                  message: message,
                  details: details
                }
              }, status: status
            end
          end
        end

        rescue_from StandardError do |e|
          render_application_error(
            error: e,
            status: :internal_server_error,
            code: 500,
            message: e.to_s
          )
        end

        rescue_from ApplicationError do |e|
          render_application_error(
            error: e,
            status: e.class.status,
            code: e.class.code,
            message: e.message || e.class.message,
            details: e.respond_to?(:details) ? e.details : nil
          )
        end

        rescue_from Pundit::NotAuthorizedError do |e|
          render_application_error(
            error: e,
            status: Error::ForbiddenError.status,
            code: Error::ForbiddenError.code,
            message: Error::ForbiddenError.message
          )
        end

        rescue_from ActiveRecord::RecordNotFound do |e|
          render_application_error(
            error: e,
            status: Error::NotFoundError.status,
            code: Error::NotFoundError.code,
            message: Error::NotFoundError.message
          )
        end

        rescue_from ActiveRecord::RecordInvalid do |e|
          details = e.record.errors.group_by_attribute.transform_values do |errors|
            errors.map do |error|
              {
                type: error.type,
                message: error.message,
                options: error.options,
                details: error.details
              }
            end
          end

          render_application_error(
            error: e,
            status: UnprocessableEntityError.status,
            code: UnprocessableEntityError.code,
            message: UnprocessableEntityError.message,
            details: details
          )
        end
      end
    end
  end
end
