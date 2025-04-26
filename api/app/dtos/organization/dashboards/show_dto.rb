module Organization
  module Dashboards
    class YtdTotalRevenues < OpenApiDto
      field "this_year", :decimal
      field "last_year", :decimal
    end
    class Kpis < OpenApiDto
      field "ytd_total_revenues", :object, subtype: YtdTotalRevenues
    end
    class DashboardData < OpenApiDto
      field "kpis", :object, subtype: Kpis
    end
    class ShowDto < OpenApiDto
      field "result", :object, subtype: DashboardData
    end
  end
end
