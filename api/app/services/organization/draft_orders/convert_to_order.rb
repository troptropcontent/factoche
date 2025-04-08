module Organization
  module DraftOrders
    class ConvertToOrder
      include ApplicationService

      def call(draft_order_id)
        draft_order = DraftOrder.find(draft_order_id)

        ensure_draft_order_have_not_been_converted_already!(draft_order)

        order, order_version = ActiveRecord::Base.transaction do
          order, order_version = duplicate_draft_order_into_new_order!(draft_order)

          draft_order.update!(posted: true, posted_at: Time.current())

          [ order, order_version ]
        end

        trigger_pdf_generation_job(order_version)

        order
      end

      private

      def duplicate_draft_order_into_new_order!(draft_order)
        r = Projects::Duplicate.call(draft_order, Order)
        raise r.error if r.failure?

        [ r.data[:new_project], r.data[:new_project_version] ]
      end

      def ensure_draft_order_have_not_been_converted_already!(draft_order)
        # draft_order.posted? should be enought but we never know
        is_converted = draft_order.posted? || draft_order.orders.any?
        raise Error::UnprocessableEntityError, "Draft order has already been converted to an order" if is_converted
      end

      def trigger_pdf_generation_job(order_version)
        ProjectVersions::GeneratePdfJob.perform_async({ "project_version_id"=>order_version.id })
      end
    end
  end
end
