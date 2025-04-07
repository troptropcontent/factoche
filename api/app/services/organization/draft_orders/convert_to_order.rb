module Organization
  module DraftOrders
    class ConvertOrder
      include ApplicationService

      def call(draft_order_id)
        draft_order = DraftOrder.find(draft_order_id)

        ensure_draft_order_have_not_been_converted_already!(draft_order)

        order = ActiveRecord::Base.transaction do
          order = duplicate_draft_order_into_new_order!(draft_order)

          draft_order.update!(posted: true, posted_at: Time.current())

          order
        end

        trigger_pdf_generation_job(order)

        order
      end

      private

      def duplicate_draft_order_into_new_order!(draft_order)
        r = Projects::Duplicate.call(draft_order, Order)
        raise r.error if r.failure?

        r.data
      end

      def ensure_draft_order_have_not_been_converted_already!(draft_order)
        # draft_order.posted? should be enought but we never know
        is_converted = draft_order.posted? || draft_order.orders.any?
        raise Error::UnprocessableEntityError, "Draft order has already been converted to an order" if is_converted
      end

      def trigger_pdf_generation_job(order)
        ProjectVersions::GeneratePdfJob.perform_async({ "project_version_id"=>order.last_version.id })
      end
    end
  end
end
