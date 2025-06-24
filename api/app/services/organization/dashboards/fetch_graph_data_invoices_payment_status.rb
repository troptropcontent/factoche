module Organization
  module Dashboards
    # Service: Organization::Dashboards::FetchGraphDataInvoicesPaymentStatus
    #
    # Computes the percentage distribution of invoice payment statuses (`paid`, `pending`, `overdue`)
    # for a given company within the current year (or up to a specified end date).
    #
    # This service:
    # - Queries a view-backed model (`Accounting::InvoicePaymentStatus`) that computes invoice status in SQL
    # - Filters invoices by company and issue date
    # - Excludes cancelled invoices
    # - Groups invoices by status and returns the distribution as percentage values
    # - Optionally broadcasts the data to a websocket channel
    #
    # === Parameters
    # * +company_id+ - ID of the company for which to fetch invoice data
    # * +end_date+ - Optional cutoff date (default: Time.current); used to filter invoices and determine "overdue" status
    # * +websocket_channel_id+ - Optional ID of a websocket channel to broadcast the result to
    #
    # === Returns
    # A Hash with symbol keys for each payment status, and percentage values (rounded to two decimals).
    # Example:
    #   {
    #     paid: 62.5,
    #     pending: 25.0,
    #     overdue: 12.5
    #   }
    #
    # === Raises
    # * +ActiveRecord::RecordNotFound+ if the company does not exist
    # * +ArgumentError+ if +end_date+ is not in the same calendar year as +Time.current+
    #
    # === Notes
    # This service relies on a PostgreSQL view (`accounting_invoice_payment_statuses`) which determines
    # payment status based on a SQL-level current date (`now()` or a test-injected `app.now` value).
    #
    # For this reason, the +end_date+ parameter must be within the current calendar year (based on Time.current),
    # as the SQL view always evaluates due dates relative to "today".
    # If an +end_date+ from another year is passed, an ArgumentError is raised to prevent inconsistent logic.
    #
    # === WebSocket Broadcast
    # If +websocket_channel_id+ is provided, the result is also broadcasted using the key:
    #   "InvoiceStatusGraphDataGenerated"
    #
    # === Usage
    #   Organization::Dashboards::FetchGraphDataInvoicesPaymentStatus.call(
    #     company_id: 123,
    #     websocket_channel_id: "dashboard:42"
    #   )
    class FetchGraphDataInvoicesPaymentStatus
      include ApplicationService
      include Broadcastable

      PAYMENT_STATUSES = %w[paid pending overdue].freeze
      WEB_SOCKET_NOTIFICATION_KEY = "InvoiceStatusGraphDataGenerated".freeze

      def call(company_id:, end_date: Time.current, websocket_channel_id: nil)
        @company = Company.find(company_id)
        @end_date = validate_end_date!(end_date)
        @websocket_channel_id = websocket_channel_id

        status_percentages = fetch_invoice_status_percentages
        broadcast_to_channel(@websocket_channel_id, status_percentages) if @websocket_channel_id
        status_percentages
      end

      private

      def validate_end_date!(end_date)
        now_year = Time.current.year
        given_year = end_date.year

        if now_year != given_year
          raise ArgumentError, "end_date must be in the current year (#{now_year}), but was #{given_year}"
        end

        end_date
      end

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
