module Organization
  module Dashboards
    # Fetches the Year-to-Date (YTD) total revenue for a company, including both current and previous year.
    # The service calculates revenue by summing up all invoices and subtracting credit notes within the specified time range.
    #
    # @param company_id [Integer] The ID of the company to fetch revenue for
    #
    # @param end_date [Time] The end date for revenue calculation (defaults to current time)
    #
    # @param websocket_channel_id [String, nil] Optional channel ID for real-time updates
    #
    # @return [Hash] A hash containing:
    #   - ytd_revenue_for_this_year [Float] Total revenue for the current year
    #   - ytd_revenue_for_last_year [Float] Total revenue for the previous year
    class FetchKpiYtdTotalRevenue
      include ApplicationService

      NotificationChannelTypeKey = "KpiTotalRevenueGenerated".freeze

      def call(company_id:, end_date: Time.current, websocket_channel_id: nil)
        @company = Company.find(company_id)
        @end_date = end_date
        @websocket_channel_id = websocket_channel_id

        fetch_ytd_revenue_for_this_year
        fetch_ytd_revenue_for_last_year
        broadcast_to_websocket_channel if websocket_channel_id.present?

        {
          ytd_revenue_for_this_year: @ytd_revenue_for_this_year,
          ytd_revenue_for_last_year: @ytd_revenue_for_last_year
        }
      end

      private

      # Calculates the YTD revenue for a given end date by summing invoices and subtracting credit notes
      # @param end_date [Time] The end date for revenue calculation
      # @return [Float] The calculated YTD revenue
      def fetch_ytd_revenue(end_date)
        time_range = calculate_time_range(end_date)

        invoices_amount = fetch_invoices_amount(time_range)
        credit_notes_amount = fetch_credit_notes_amount(time_range)

        invoices_amount - credit_notes_amount
      end

      # Calculates the time range from the beginning of the year to the end date
      # @param end_date [Time] The end date for the range
      # @return [Range] A range from beginning of year to end date
      def calculate_time_range(end_date)
        end_date.beginning_of_year...end_date
      end

      # Fetches the total amount of invoices within the given time range
      # @param time_range [Range] The time range to fetch invoices for
      # @return [Float] The total amount of invoices
      def fetch_invoices_amount(time_range)
        Accounting::Invoice
          .where(company_id: @company.id, issue_date: time_range)
          .sum(:total_excl_tax_amount)
      end

      # Fetches the total amount of credit notes within the given time range
      # @param time_range [Range] The time range to fetch credit notes for
      # @return [Float] The total amount of credit notes
      def fetch_credit_notes_amount(time_range)
        Accounting::CreditNote
          .where(company_id: @company.id, issue_date: time_range)
          .sum(:total_excl_tax_amount)
      end

      # Fetches the YTD revenue for the current year
      def fetch_ytd_revenue_for_this_year
        @ytd_revenue_for_this_year = fetch_ytd_revenue(@end_date)
      end

      # Fetches the YTD revenue for the previous year
      def fetch_ytd_revenue_for_last_year
        @ytd_revenue_for_last_year = fetch_ytd_revenue(@end_date.last_year)
      end

      # Broadcasts the revenue data to the specified websocket channel
      def broadcast_to_websocket_channel
         ActionCable.server.broadcast(@websocket_channel_id, {
            "type" => NotificationChannelTypeKey,
            "data" => {
              "ytd_revenue_for_this_year"=> @ytd_revenue_for_this_year.to_s,
              "ytd_revenue_for_last_year"=> @ytd_revenue_for_last_year.to_s
            }
          })
      end
    end
  end
end
