module Organization
  module Dashboards
    # Service to fetch and calculate the average order completion percentage for a company
    # within a specified time range, with optional websocket broadcasting.
    #
    # @example
    #   result = FetchKpiAverageOrdersCompletionPercentage.call(
    #     company_id: 1,
    #     end_date: Time.current,
    #     websocket_channel_id: "channel_123"
    #   )
    #
    # @param company_id [Integer] The ID of the company to fetch data for
    #
    # @param end_date [Time] The end date for the calculation period (defaults to current time)
    #
    # @param websocket_channel_id [String, nil] Optional channel ID for broadcasting results
    #
    # @return [Float] The average order completion percentage
    class FetchKpiAverageOrdersCompletionPercentage
      include ApplicationService

      # The notification type key used for websocket broadcasts
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

      # Fetches the average completion percentage for orders within the specified time range
      #
      # @return [Float] The average completion percentage
      def fetch_average_order_completion_percentage
        time_range = @end_date.beginning_of_year...@end_date

        order_completion_percentage = Organization::Dashboards::OrderCompletionPercentage
          .joins(:order)
          .where(order: { created_at: time_range, company_id: @company.id })
          .order("order_completion_percentages.order_id")
          .average("order_completion_percentages.completion_percentage")

        order_completion_percentage&.round(2) || 0.to_d
      end

      # Broadcasts the completion percentage data to the specified websocket channel
      #
      # @param average_order_completion_percentage [Float] The completion percentage to broadcast
      def broadcast_to_websocket_channel(average_order_completion_percentage)
        ActionCable.server.broadcast(@websocket_channel_id, {
          "type" => NotificationChannelTypeKey,
          "data" => average_order_completion_percentage
        })
      end
    end
  end
end
