module Organization
  module Dashboards
    class FetchGraphDataMonthlyRevenues
      include ApplicationService
      include Broadcastable

      # The notification type key used for websocket broadcasts
      WEB_SOCKET_NOTIFICATION_KEY = "GraphDataMonthlyRevenuesGenerated".freeze

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

        monthly_revenues.each_with_object(empty_monthly_revenues_chart_data) { |monthly_revenue, monthly_revenues_chart_data|
          monthly_revenues_chart_data_key = Date::MONTHNAMES[monthly_revenue.month].downcase
          monthly_revenues_chart_data[monthly_revenues_chart_data_key] = monthly_revenue.total_revenue
        }
      end

      def empty_monthly_revenues_chart_data
        Date::MONTHNAMES.each_with_object({}) { |month_name, base_monthly_revenues|
          base_monthly_revenues[month_name.downcase] = nil if month_name
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
