module Organization
  module Dashboards
    class FetchData
      include ApplicationService

      def call(company_id:, end_date: Time.current, websocket_channel_id: nil)
        @company = Company.find(company_id)
        @end_date = end_date
        @websocket_channel_id = websocket_channel_id

        {
          kpis: {
            ytd_total_revenues: fetch_ytd_total_revenues!
          }
        }
      end

      private

      def fetch_ytd_total_revenues!
        r = FetchKpiYtdTotalRevenue.call(company_id: @company.id, end_date: @end_date, websocket_channel_id: @websocket_channel_id)
        raise r.error if r.failure?

        {
          this_year: r.data.fetch(:ytd_revenue_for_this_year),
          last_year: r.data.fetch(:ytd_revenue_for_last_year)
        }
      end
    end
  end
end
