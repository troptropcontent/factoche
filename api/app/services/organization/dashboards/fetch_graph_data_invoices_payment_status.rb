module Organization
  module Dashboards
    class FetchGraphDataInvoicesPaymentStatus
      include ApplicationService
      include Broadcastable

      PAYMENT_STATUSES = %w[paid pending overdue].freeze
      WEB_SOCKET_NOTIFICATION_KEY = "InvoiceStatusGraphDataGenerated".freeze

      def call(company_id:, end_date: Time.current, websocket_channel_id: nil)
        @company = Company.find(company_id)
        @end_date = end_date
        @websocket_channel_id = websocket_channel_id

        status_percentages = fetch_invoice_status_percentages
        broadcast_to_channel(@websocket_channel_id, status_percentages) if @websocket_channel_id
        status_percentages
      end

      private

      def fetch_invoice_status_percentages
        base_query = Accounting::InvoicePaymentStatus
          .joins(:invoice)
          .where(invoice: { company_id: @company.id, issue_date: @end_date.beginning_of_year..@end_date })
          .where.not(invoice: { status: "cancelled" })


        counts_by_status = base_query.group(:status).count
        total = counts_by_status.values.sum

        PAYMENT_STATUSES.index_with do |status|
          count = counts_by_status[status] || 0
          total.zero? ? 0.to_d : ((count.to_d / total)).round(2)
        end.symbolize_keys
      end
    end
  end
end
