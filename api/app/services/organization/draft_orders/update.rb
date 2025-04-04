module Organization
  module DraftOrders
    class Update
      include ApplicationService

      def call(draft_order, params)
        @draft_order = draft_order
        @params = params

        ensure_draft_order_is_updatable!

        update_draft_order_and_enqueue_pdf_generation_job!
      end

      private

      def ensure_draft_order_is_updatable!
        raise Error::UnprocessableEntityError, "Draft Order has already been posted or converted to an order" if @draft_order.posted? || @draft_order.orders.any?
      end

      def update_draft_order_and_enqueue_pdf_generation_job!
        result = Projects::Update.call(@draft_order, @params)
        raise Error::UnprocessableEntityError, result.error if result.failure?

        ProjectVersions::GeneratePdfJob.perform_async({ "project_version_id"=>result.data[:version].id })

        result.data[:project]
      end
    end
  end
end
