import { KpiCardTotalRevenue } from "./private/kpi-card-total-revenue";
import { KpiCardAverageOrdersCompletionPercentage } from "./private/kpi-card-average_orders_completion_percentage";
import { KpiCardOrdersDetails } from "./private/kpi-card-orders-details";
import { ChartCardRevenueOverTime } from "./private/chart-card-revenue-over-time";
import { ChartCardRevenueByClient } from "./private/chart-card-revenue-by-client";
import { ChartDataUncompletedOrdersDetails } from "./private/chart-data-uncompleted-orders-details";
import { ChartCardInvoicesPaymentStatus } from "./private/chart-card-invoices-payment-status";

export default function Dashboard({ companyId }: { companyId: number }) {
  return (
    <div className="flex min-h-screen bg-background">
      <div className="flex flex-1 flex-col">
        <main className="flex-1 p-4 sm:p-6 lg:p-8">
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            <KpiCardTotalRevenue companyId={companyId} />
            <KpiCardAverageOrdersCompletionPercentage companyId={companyId} />
            <KpiCardOrdersDetails companyId={companyId} />
          </div>

          {/* Charts Section */}
          <div className="mt-6 grid gap-6 md:grid-cols-2 lg:grid-cols-3">
            <ChartCardRevenueOverTime companyId={companyId} />
            <ChartCardInvoicesPaymentStatus companyId={companyId} />
            <ChartCardRevenueByClient companyId={companyId} />
            <ChartDataUncompletedOrdersDetails companyId={companyId} />
          </div>
        </main>
      </div>
    </div>
  );
}
