module Organization
  module Dashboards
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

      def fetch_ytd_revenue(end_date)
        time_range = calculate_time_range(end_date)

        invoices_amount = fetch_invoices_amount(time_range)
        credit_notes_amount = fetch_credit_notes_amount(time_range)

        invoices_amount - credit_notes_amount
      end

      def calculate_time_range(end_date)
        end_date.beginning_of_year...end_date
      end

      def fetch_invoices_amount(time_range)
        Accounting::Invoice
          .where(company_id: @company.id, issue_date: time_range)
          .sum(:total_excl_tax_amount)
      end

      def fetch_credit_notes_amount(time_range)
        Accounting::CreditNote
          .where(company_id: @company.id, issue_date: time_range)
          .sum(:total_excl_tax_amount)
      end

      def fetch_ytd_revenue_for_this_year
        @ytd_revenue_for_this_year = fetch_ytd_revenue(@end_date)
      end

      def fetch_ytd_revenue_for_last_year
        @ytd_revenue_for_last_year = fetch_ytd_revenue(@end_date.last_year)
      end

      def broadcast_to_websocket_channel
         ActionCable.server.broadcast(@websocket_channel_id, {
            "type" => NotificationChannelTypeKey,
            "data" => {
              "ytd_revenue_for_this_year"=> @ytd_revenue_for_this_year,
              "ytd_revenue_for_last_year"=> @ytd_revenue_for_last_year
            }
          })
      end
    end
  end
end
