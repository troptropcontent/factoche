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

    class MonthlyRevenues < OpenApiDto
      field "january", :decimal, required: false
      field "february", :decimal, required: false
      field "march", :decimal, required: false
      field "april", :decimal, required: false
      field "may", :decimal, required: false
      field "june", :decimal, required: false
      field "july", :decimal, required: false
      field "august", :decimal, required: false
      field "september", :decimal, required: false
      field "october", :decimal, required: false
      field "november", :decimal, required: false
      field "december", :decimal, required: false
    end

    class RevenueByClient < OpenApiDto
      field "client_id", :integer
      field "client_name", :string
      field "revenue", :decimal
    end

    class OrderCompletionPercentageSchema < OpenApiDto
      field "id", :integer
      field "name", :string
      field "order_total_amount", :decimal
      field "invoiced_total_amount", :decimal
      field "completion_percentage", :decimal
    end

    class InvoicePaymentStatusDistribution < OpenApiDto
      field "pending", :decimal
      field "paid", :decimal
      field "overdue", :decimal
    end

    class ChartsData < OpenApiDto
      field "monthly_revenues", :object, subtype: MonthlyRevenues
      field "revenue_by_client", :array, subtype: RevenueByClient
      field "order_completion_percentages", :array, subtype: OrderCompletionPercentageSchema
      field "invoice_payment_status_distribution", :object, subtype: InvoicePaymentStatusDistribution
    end

    class DashboardData < OpenApiDto
      field "kpis", :object, subtype: Kpis
      field "charts_data", :object, subtype: ChartsData
    end

    class ShowDto < OpenApiDto
      field "result", :object, subtype: DashboardData
    end
  end
end
