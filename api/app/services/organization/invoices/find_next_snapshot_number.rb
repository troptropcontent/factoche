module Organization
  module Invoices
    class FindNextSnapshotNumber
      include ApplicationService

      def call(order_id)
        order = Organization::Order.find(order_id)
        order_version_ids = order.versions.pluck(:id)
        already_recorded_invoice_count = Accounting::Invoice.where(holder_id: order_version_ids).posted.count

        already_recorded_invoice_count + 1
      end
    end
  end
end
