module Organization
  module Orders
    class Update
      include ApplicationService

      def call(order_id, params)
        @order = Order.find(order_id)
        @params = params

        update_order_and_enqueue_pdf_generation_job!
      end

      private

      def update_order_and_enqueue_pdf_generation_job!
        result = Projects::Update.call(@order, @params)
        raise Error::UnprocessableEntityError, result.error if result.failure?

        ProjectVersions::GeneratePdfJob.perform_async({ "project_version_id"=>result.data[:version].id })

        result.data[:project]
      end
    end
  end
end
