import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

import { KpiCardTotalRevenue } from "./private/kpi-card-total-revenue";
import { KpiCardAverageOrdersCompletionPercentage } from "./private/kpi-card-average_orders_completion_percentage";
import { KpiCardOrdersDetails } from "./private/kpi-card-orders-details";
import { ChartCardRevenueOverTime } from "./private/chart-card-revenue-over-time";
import { ChartCardRevenueByClient } from "./private/chart-card-revenue-by-client";

// Sample data for the charts

const projectProgressData = [
  { name: "Office Renovation", progress: 85, billed: 42500, total: 50000 },
  { name: "Residential Complex", progress: 62, billed: 93000, total: 150000 },
  { name: "Commercial Building", progress: 45, billed: 67500, total: 150000 },
  { name: "School Extension", progress: 92, billed: 138000, total: 150000 },
  { name: "Hospital Wing", progress: 30, billed: 90000, total: 300000 },
];

const upcomingInvoicesData = [
  {
    id: "INV-2023-089",
    client: "ABC Corporation",
    project: "Office Renovation",
    progress: 85,
    nextBilling: "2023-11-15",
    estimatedAmount: 7500,
  },
  {
    id: "INV-2023-092",
    client: "XYZ Enterprises",
    project: "Commercial Building",
    progress: 45,
    nextBilling: "2023-11-18",
    estimatedAmount: 22500,
  },
  {
    id: "INV-2023-095",
    client: "123 Properties",
    project: "Residential Complex",
    progress: 62,
    nextBilling: "2023-11-20",
    estimatedAmount: 15000,
  },
  {
    id: "INV-2023-098",
    client: "Global Constructions",
    project: "School Extension",
    progress: 92,
    nextBilling: "2023-11-25",
    estimatedAmount: 12000,
  },
  {
    id: "INV-2023-102",
    client: "City Developers",
    project: "Hospital Wing",
    progress: 30,
    nextBilling: "2023-11-30",
    estimatedAmount: 30000,
  },
];

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
            <ChartCardRevenueByClient companyId={companyId} />
            {/* Progress by Project */}
            <Card className="col-span-full">
              <CardHeader>
                <CardTitle>Progress by Project</CardTitle>
                <CardDescription>
                  Completion percentage and billing status
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {projectProgressData.map((project) => (
                    <div key={project.name} className="space-y-2">
                      <div className="flex items-center justify-between">
                        <span className="font-medium">{project.name}</span>
                        <span className="text-sm text-muted-foreground">
                          ${project.billed.toLocaleString()} / $
                          {project.total.toLocaleString()}
                        </span>
                      </div>
                      <div className="flex items-center gap-2">
                        <Progress value={project.progress} className="h-2" />
                        <span className="text-sm font-medium">
                          {project.progress}%
                        </span>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>

            {/* Upcoming Invoices */}
            <Card className="col-span-3">
              <CardHeader>
                <CardTitle>
                  Upcoming Invoices / Next Billing Opportunity
                </CardTitle>
                <CardDescription>
                  Projects ready for next billing cycle
                </CardDescription>
              </CardHeader>
              <CardContent>
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Invoice ID</TableHead>
                      <TableHead>Client</TableHead>
                      <TableHead>Project</TableHead>
                      <TableHead>Progress</TableHead>
                      <TableHead>Next Billing Date</TableHead>
                      <TableHead className="text-right">
                        Estimated Amount
                      </TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {upcomingInvoicesData.map((invoice) => (
                      <TableRow key={invoice.id}>
                        <TableCell className="font-medium">
                          {invoice.id}
                        </TableCell>
                        <TableCell>{invoice.client}</TableCell>
                        <TableCell>{invoice.project}</TableCell>
                        <TableCell>
                          <div className="flex items-center gap-2">
                            <Progress
                              value={invoice.progress}
                              className="h-2 w-24"
                            />
                            <span className="text-sm">{invoice.progress}%</span>
                          </div>
                        </TableCell>
                        <TableCell>
                          {new Date(invoice.nextBilling).toLocaleDateString()}
                        </TableCell>
                        <TableCell className="text-right">
                          ${invoice.estimatedAmount.toLocaleString()}
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </CardContent>
              <CardFooter className="flex justify-end">
                <Button variant="outline">View All Invoices</Button>
              </CardFooter>
            </Card>
          </div>
        </main>
      </div>
    </div>
  );
}
