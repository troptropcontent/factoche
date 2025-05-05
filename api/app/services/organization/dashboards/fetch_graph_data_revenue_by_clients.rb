module Organization
  module Dashboards
    class FetchGraphDataRevenueByClients
      include ApplicationService
      include Broadcastable

      # The notification type key used for websocket broadcasts
      WEB_SOCKET_NOTIFICATION_KEY = "GraphDataRevenueByClientsGenerated".freeze

      def call(company_id:, end_date: Time.current, websocket_channel_id: nil)
        @company = Company.find(company_id)
        @time_range = end_date.beginning_of_year...end_date

        monthly_revenue = fetch_revenue_by_clients!
        broadcast_to_channel(websocket_channel_id, monthly_revenue) if websocket_channel_id
        monthly_revenue
      end

      private

      def fetch_revenue_by_clients!
        Organization::Client.joins("LEFT JOIN accounting_financial_transactions as invoices ON invoices.client_id = organization_clients.id AND invoices.type = 'Accounting::Invoice' LEFT JOIN accounting_financial_transactions as credit_notes ON credit_notes.holder_id = invoices.id AND credit_notes.type = 'Accounting::CreditNote'")
                            .where(company_id: @company.id, invoices: { issue_date: @time_range })
                            .group("organization_clients.id")
                            .pluck(Arel.sql("organization_clients.id as client_id, SUM(COALESCE(invoices.total_excl_tax_amount, 0) - COALESCE(credit_notes.total_excl_tax_amount, 0)) as revenue"))
                            .map { |(client_id, revenue)| { client_id:, revenue: } }
      end
    end
  end
end
