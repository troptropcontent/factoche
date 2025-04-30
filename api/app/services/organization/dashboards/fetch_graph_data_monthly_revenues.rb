module Organization
  module Dashboards
    class FetchGraphDataMonthlyRevenues
      include ApplicationService
      include Broadcastable

      # The notification type key used for websocket broadcasts
      WEB_SOCKET_NOTIFICATION_KEY = "GraphDataMonthlyRevenuesGenerated".freeze
      EMPTY_MONTHLY_REVENUES_CHART_DATA = {
        "1": nil,
        "2": nil,
        "3": nil,
        "4": nil,
        "5": nil,
        "6": nil,
        "7": nil,
        "8": nil,
        "9": nil,
        "10": nil,
        "11": nil,
        "12": nil
      }.freeze

      def call(company_id:, year: Time.current.year, websocket_channel_id: nil)
        @company = Company.find(company_id)
        @year = year
        @websocket_channel_id = websocket_channel_id

        monthly_revenue = fetch_monthly_revenue
        broadcast_to_channel(websocket_channel_id, monthly_revenue) if @websocket_channel_id
        monthly_revenue
      end

      private

      def fetch_monthly_revenue
        monthly_revenues = MonthlyRevenue.where(year: @year, company_id: @company.id)

        monthly_revenues.each_with_object(EMPTY_MONTHLY_REVENUES_CHART_DATA.deep_dup) { |monthly_revenue, monthly_revenues_chart_data|
          monthly_revenues_chart_data[monthly_revenue.month.to_s.to_sym] = monthly_revenue.total_revenue
        }
      end

      def broadcast_to_websocket_channel(monthly_revenue)
        ActionCable.server.broadcast(@websocket_channel_id, {
          "type" => NotificationChannelTypeKey,
          "data" => monthly_revenue
        })
      end
    end
  end
end
