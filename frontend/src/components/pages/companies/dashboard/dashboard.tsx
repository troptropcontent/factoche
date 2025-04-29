import {
  BarChart,
  Bar,
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
} from "recharts";
import { Layers } from "lucide-react";

import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
} from "@/components/ui/chart";
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

// Sample data for the charts
const revenueData = [
  { month: "Jan", revenue: 12500 },
  { month: "Feb", revenue: 18200 },
  { month: "Mar", revenue: 15800 },
  { month: "Apr", revenue: 21000 },
  { month: "May", revenue: 19500 },
  { month: "Jun", revenue: 24800 },
  { month: "Jul", revenue: 27300 },
  { month: "Aug", revenue: 25100 },
  { month: "Sep", revenue: 29800 },
  { month: "Oct", revenue: 31200 },
  { month: "Nov", revenue: 28900 },
  { month: "Dec", revenue: 33500 },
];

const invoiceStatusData = [
  { name: "Paid", value: 68, color: "#10b981" },
  { name: "Pending", value: 22, color: "#f59e0b" },
  { name: "Overdue", value: 10, color: "#ef4444" },
];

const projectProgressData = [
  { name: "Office Renovation", progress: 85, billed: 42500, total: 50000 },
  { name: "Residential Complex", progress: 62, billed: 93000, total: 150000 },
  { name: "Commercial Building", progress: 45, billed: 67500, total: 150000 },
  { name: "School Extension", progress: 92, billed: 138000, total: 150000 },
  { name: "Hospital Wing", progress: 30, billed: 90000, total: 300000 },
];

const topClientsData = [
  { name: "ABC Corporation", revenue: 125000 },
  { name: "XYZ Enterprises", revenue: 98000 },
  { name: "123 Properties", revenue: 87500 },
  { name: "Global Constructions", revenue: 76200 },
  { name: "City Developers", revenue: 65800 },
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

// KPI summary data
const kpiData = {
  totalRevenue: 285000,
  amountDue: 87000,
  avgCompletion: 63,
  activeProjects: 8,
  completedProjects: 12,
};

export default function Dashboard({ companyId }: { companyId: number }) {
  return (
    <div className="flex min-h-screen bg-background">
      <div className="flex flex-1 flex-col">
        <main className="flex-1 p-4 sm:p-6 lg:p-8">
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            <KpiCardTotalRevenue companyId={companyId} />
            <KpiCardAverageOrdersCompletionPercentage companyId={companyId} />
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Projects</CardTitle>
                <Layers className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">
                  {kpiData.activeProjects} Active
                </div>
                <p className="text-xs text-muted-foreground">
                  {kpiData.completedProjects} completed this year
                </p>
              </CardContent>
            </Card>
          </div>

          {/* Charts Section */}
          <div className="mt-6 grid gap-6 md:grid-cols-2 lg:grid-cols-3">
            {/* Revenue Over Time */}
            <Card className="col-span-2">
              <CardHeader>
                <CardTitle>Revenue Over Time</CardTitle>
                <CardDescription>Monthly invoiced amount</CardDescription>
              </CardHeader>
              <CardContent>
                <ChartContainer
                  config={{
                    revenue: {
                      label: "Revenue",
                      color: "hsl(var(--chart-1))",
                    },
                  }}
                  className="aspect-[4/3]"
                >
                  <ResponsiveContainer width="100%" height="100%">
                    <LineChart data={revenueData}>
                      <CartesianGrid strokeDasharray="3 3" />
                      <XAxis dataKey="month" />
                      <YAxis tickFormatter={(value) => `$${value / 1000}k`} />
                      <ChartTooltip
                        content={({ active, payload }) => {
                          if (active && payload && payload.length) {
                            return (
                              <div className="rounded-lg border bg-background p-2 shadow-sm">
                                <div className="grid grid-cols-2 gap-2">
                                  <div className="flex flex-col">
                                    <span className="text-[0.70rem] uppercase text-muted-foreground">
                                      Month
                                    </span>
                                    <span className="font-bold text-muted-foreground">
                                      {payload[0].payload.month}
                                    </span>
                                  </div>
                                  <div className="flex flex-col">
                                    <span className="text-[0.70rem] uppercase text-muted-foreground">
                                      Revenue
                                    </span>
                                    <span className="font-bold">
                                      ${payload[0].value.toLocaleString()}
                                    </span>
                                  </div>
                                </div>
                              </div>
                            );
                          }
                          return null;
                        }}
                      />
                      <Line
                        type="monotone"
                        dataKey="revenue"
                        stroke="var(--color-revenue)"
                        strokeWidth={2}
                        activeDot={{ r: 8 }}
                      />
                    </LineChart>
                  </ResponsiveContainer>
                </ChartContainer>
              </CardContent>
            </Card>

            {/* Outstanding vs. Paid Invoices */}
            <Card>
              <CardHeader>
                <CardTitle>Invoice Status</CardTitle>
                <CardDescription>Paid vs. pending vs. overdue</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="h-[300px]">
                  <ResponsiveContainer width="100%" height="100%">
                    <PieChart>
                      <Pie
                        data={invoiceStatusData}
                        cx="50%"
                        cy="50%"
                        innerRadius={60}
                        outerRadius={80}
                        paddingAngle={5}
                        dataKey="value"
                      >
                        {invoiceStatusData.map((entry, index) => (
                          <Cell key={`cell-${index}`} fill={entry.color} />
                        ))}
                      </Pie>
                      <Tooltip
                        content={({ active, payload }) => {
                          if (active && payload && payload.length) {
                            return (
                              <div className="rounded-lg border bg-background p-2 shadow-sm">
                                <div className="flex flex-col">
                                  <span className="font-bold">
                                    {payload[0].name}
                                  </span>
                                  <span className="text-muted-foreground">
                                    {payload[0].value}%
                                  </span>
                                </div>
                              </div>
                            );
                          }
                          return null;
                        }}
                      />
                    </PieChart>
                  </ResponsiveContainer>
                </div>
                <div className="mt-4 flex justify-center space-x-4">
                  {invoiceStatusData.map((item) => (
                    <div key={item.name} className="flex items-center">
                      <div
                        className="mr-1 h-3 w-3 rounded-full"
                        style={{ backgroundColor: item.color }}
                      />
                      <span className="text-sm">
                        {item.name} ({item.value}%)
                      </span>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>

            {/* Progress by Project */}
            <Card className="col-span-2">
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

            {/* Top Clients by Revenue */}
            <Card>
              <CardHeader>
                <CardTitle>Top Clients by Revenue</CardTitle>
                <CardDescription>Your most profitable clients</CardDescription>
              </CardHeader>
              <CardContent>
                <ChartContainer
                  config={{
                    revenue: {
                      label: "Revenue",
                      color: "hsl(var(--chart-2))",
                    },
                  }}
                  className="aspect-[4/3]"
                >
                  <ResponsiveContainer width="100%" height="100%">
                    <BarChart
                      data={topClientsData}
                      layout="vertical"
                      margin={{ top: 5, right: 30, left: 20, bottom: 5 }}
                    >
                      <CartesianGrid strokeDasharray="3 3" />
                      <XAxis
                        type="number"
                        tickFormatter={(value) => `$${value / 1000}k`}
                      />
                      <YAxis
                        type="category"
                        dataKey="name"
                        width={100}
                        tick={{ fontSize: 12 }}
                      />
                      <ChartTooltip content={<ChartTooltipContent />} />
                      <Bar dataKey="revenue" fill="var(--color-revenue)" />
                    </BarChart>
                  </ResponsiveContainer>
                </ChartContainer>
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
