module Organization
  module Dashboards
    class YtdTotalRevenues < OpenApiDto
      field "this_year", :decimal
      field "last_year", :decimal
    end
    class OrderDetails < OpenApiDto
      field "completed_orders_count", :integer
      field "not_completed_orders_count", :integer
    end
    class Kpis < OpenApiDto
      field "ytd_total_revenues", :object, subtype: YtdTotalRevenues
      field "average_orders_completion_percentage", :decimal
      field "orders_details", :object, subtype: OrderDetails
    end
    class DashboardData < OpenApiDto
      field "kpis", :object, subtype: Kpis
    end
    class ShowDto < OpenApiDto
      field "result", :object, subtype: DashboardData
    end
  end
end
