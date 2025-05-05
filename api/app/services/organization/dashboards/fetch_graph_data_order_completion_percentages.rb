module Organization
  module Dashboards
    class FetchGraphDataOrderCompletionPercentages
      include ApplicationService
      include Broadcastable

      # The notification type key used for websocket broadcasts
      WEB_SOCKET_NOTIFICATION_KEY = "GraphDataOrderCompletionPercentagesGenerated".freeze

      def call(company_id:, end_date: Time.current, websocket_channel_id: nil)
        @company = Company.find(company_id)
        @time_range = end_date.beginning_of_year...end_date

        order_completion_percentages = fetch_order_completion_percentages
        broadcast_to_channel(websocket_channel_id, order_completion_percentages) if websocket_channel_id
        order_completion_percentages
      end

      private

      def fetch_order_completion_percentages
        Organization::Dashboards::OrderCompletionPercentage.joins({ order: :client })
                                                           .where({ order: { company_id: @company.id, created_at: @time_range } })
                                                           .order("order_completion_percentages.order_id")
                                                           .pluck("order_completion_percentages.order_id, \"order\".name, order_completion_percentages.order_total_amount, order_completion_percentages.invoiced_total_amount, order_completion_percentages.completion_percentage")
                                                           .map { |(id, name, order_total_amount, invoiced_total_amount, completion_percentage)| { id:, name:, order_total_amount:, invoiced_total_amount:, completion_percentage: } }
      end
    end
  end
end
