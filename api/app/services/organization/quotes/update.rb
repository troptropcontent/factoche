module Organization
  module Quotes
    class Update
      include ApplicationService

      def call(quote, params)
        @quote = quote
        @params = params

        ensure_quote_is_updatable!

        update_quote!
      end

      private

      def ensure_quote_is_updatable!
        raise Error::UnprocessableEntityError, "Quote has already been posted or converted to a draft order" if @quote.posted? || @quote.draft_orders.any?
      end

      def update_quote!
        result = Projects::Update.call(@quote, @params)
        raise Error::UnprocessableEntityError, result.error if result.failure?

        result.data[:project]
      end
    end
  end
end
