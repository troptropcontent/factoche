module Organization
  module Dashboards
    # Service to fetch KPI order details for a company and optionally broadcast them via websocket.
    #
    # This service calculates the number of completed and not completed orders for a company
    # within the current year up to a given end date.
    #
    # @example
    #   Organization::Dashboards::FetchKpiOrdersDetails.new.call(
    #     company_id: 1,
    #     end_date: Time.current,
    #     websocket_channel_id: "some_channel"
    #   )
    class FetchKpiOrdersDetails
      include ApplicationService

      NotificationChannelTypeKey = "KpiOrdersDetailsGenerated".freeze

      # Fetches KPI order details and optionally broadcasts them to a websocket channel.
      #
      # @param company_id [Integer] The ID of the company.
      # @param end_date [Time] The end date for the KPI calculation (default: Time.current).
      # @param websocket_channel_id [String, nil] The websocket channel ID to broadcast to (optional).
      # @return [Hash] Hash with :completed_orders_count and :not_completed_orders_count.
      def call(company_id:, end_date: Time.current, websocket_channel_id: nil)
        @company = Company.find(company_id)
        @end_date = end_date
        @websocket_channel_id = websocket_channel_id

        orders_details = fetch_orders_details
        broadcast_to_websocket_channel(orders_details) if @websocket_channel_id
        orders_details
      end

      private

      # Calculates the number of completed and not completed orders for the company
      # in the current year up to @end_date.
      #
      # @return [Hash] Hash with :completed_orders_count and :not_completed_orders_count.
      def fetch_orders_details
        time_range = @end_date.beginning_of_year...@end_date
        base_query = Organization::Dashboards::OrderCompletionPercentage
        .joins(:order)
        .where(order: { created_at: time_range, company_id: @company.id })
        .order("order_completion_percentages.order_id")

        completed_orders_count = base_query.where(order_completion_percentages: { completion_percentage: 1.0 }).count
        not_completed_orders_count = base_query.count - completed_orders_count

        {
          completed_orders_count: completed_orders_count,
          not_completed_orders_count: not_completed_orders_count
        }
      end

      # Broadcasts the orders details to the specified websocket channel.
      #
      # @param orders_details [Hash] The orders details to broadcast.
      # @return [void]
      def broadcast_to_websocket_channel(orders_details)
        ActionCable.server.broadcast(@websocket_channel_id, {
          "type" => NotificationChannelTypeKey,
          "data" => orders_details.stringify_keys
        })
      end
    end
  end
end
