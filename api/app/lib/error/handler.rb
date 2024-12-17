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
              status: e.status,
              code: e.code,
              message: e.message
            }
          }, status: e.status
        end
      end
    end
  end
end
