module Organization
  module Quotes
    class Update
      include ApplicationService

      def call(quote, params)
        @quote = quote
        @params = params

        ensure_quote_is_updatable!

        update_quote_and_enqueue_pdf_generation_job!
      end

      private

      def ensure_quote_is_updatable!
        raise Error::UnprocessableEntityError, "Quote has already been posted or converted to a draft order" if @quote.posted? || @quote.draft_orders.any?
      end

      def update_quote_and_enqueue_pdf_generation_job!
        result = Projects::Update.call(@quote, @params)
        raise Error::UnprocessableEntityError, result.error if result.failure?

        ProjectVersions::GeneratePdfJob.perform_async({ "project_version_id"=>result.data[:version].id })

        result.data[:project]
      end
    end
  end
end
