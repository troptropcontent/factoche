module Organization
  module Dashboards
    class FetchKpiAverageOrdersCompletionPercentage
      include ApplicationService

      NotificationChannelTypeKey = "KpiAverageOrderCompletionGenerated".freeze

      def call(company_id:, end_date: Time.current, websocket_channel_id: nil)
        @company = Company.find(company_id)
        @end_date = end_date
        @websocket_channel_id = websocket_channel_id

        average_order_completion_percentage = fetch_average_order_completion_percentage
        broadcast_to_websocket_channel(average_order_completion_percentage) if @websocket_channel_id
        average_order_completion_percentage
      end

      private

      def fetch_average_order_completion_percentage
        time_range = @end_date.beginning_of_year...@end_date

        Organization::Dashboards::OrderCompletionPercentage.joins(:order).where(order: { created_at: time_range, company_id: @company.id }).order("order_completion_percentages.order_id").average("order_completion_percentages.completion_percentage")
      end

      # Broadcasts the revenue data to the specified websocket channel
      def broadcast_to_websocket_channel(average_order_completion_percentage)
         ActionCable.server.broadcast(@websocket_channel_id, {
            "type" => NotificationChannelTypeKey,
            "data" => average_order_completion_percentage
          })
      end
    end
  end
end
