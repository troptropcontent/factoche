import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { ChartContainer, ChartTooltip } from "@/components/ui/chart";
import { Skeleton } from "@/components/ui/skeleton";
import { useChannelSubscription } from "@/hooks/use-channel-subscription";
import { Api } from "@/lib/openapi-fetch-query-client";
import { paths } from "@/lib/openapi-fetch-schemas";
import { useState } from "react";
import { useTranslation } from "react-i18next";
import {
  CartesianGrid,
  Line,
  LineChart,
  ResponsiveContainer,
  XAxis,
  YAxis,
} from "recharts";

type RawRevenueOtherTimeType =
  paths["/api/v1/organization/companies/{company_id}/dashboard"]["get"]["responses"]["200"]["content"]["application/json"]["result"]["charts_data"]["monthly_revenues"];

const LoadingContent = () => <Skeleton className="h-full w-full" />;

const LoadedContent = ({ data }: { data: RawRevenueOtherTimeType }) => {
  const { t } = useTranslation();

  let mappedData: { month: string; revenue: number | null }[] = [];
  for (const [key, value] of Object.entries(data)) {
    mappedData = [
      ...mappedData,
      {
        month: key,
        revenue: value == null ? value : Number(value),
      },
    ];
  }
  return (
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
          <LineChart data={mappedData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis
              dataKey="month"
              tickFormatter={(value) =>
                t(
                  `pages.companies.dashboard.charts.revenue_over_time.${value}_short`
                )
              }
            />
            <YAxis tickFormatter={(value) => `${value / 1000}k €`} />
            <ChartTooltip
              content={({ active, payload }) => {
                if (active && payload && payload.length) {
                  return (
                    <div className="rounded-lg border bg-background p-2 shadow-sm">
                      <div className="grid grid-cols-2 gap-2">
                        <div className="flex flex-col">
                          <span className="text-[0.70rem] uppercase text-muted-foreground">
                            {t(
                              "pages.companies.dashboard.charts.revenue_over_time.tooltip_label_month"
                            )}
                          </span>
                          <span className="font-bold text-muted-foreground">
                            {t(
                              `pages.companies.dashboard.charts.revenue_over_time.${payload[0].payload.month}`
                            )}
                          </span>
                        </div>
                        <div className="flex flex-col">
                          <span className="text-[0.70rem] uppercase text-muted-foreground">
                            {t(
                              "pages.companies.dashboard.charts.revenue_over_time.tooltip_label_revenue"
                            )}
                          </span>
                          <span className="font-bold">
                            {t("common.number_in_currency", {
                              amount: payload[0].value,
                            })}
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
  );
};

const ChartCardRevenueOverTime = ({ companyId }: { companyId: number }) => {
  const [revenueOtherTimeFromWebsocket, setRevenueOtherTimeFromWebsocket] =
    useState<RawRevenueOtherTimeType | undefined>(undefined);

  const isSocketConnected = useChannelSubscription(
    `NotificationsChannel`,
    ({ data, type }) => {
      if (type === "GraphDataMonthlyRevenuesGenerated") {
        console.log("Data received : ", data);
        setRevenueOtherTimeFromWebsocket(data);
      }
    }
  );

  const { data: revenueOtherTimeFromServer } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/dashboard",
    { params: { path: { company_id: companyId } } },
    {
      select: ({
        result: {
          charts_data: { monthly_revenues },
        },
      }) => monthly_revenues,
      enabled: isSocketConnected,
    }
  );

  // Use websocket data if available, otherwise fall back to query data
  const displayData =
    revenueOtherTimeFromWebsocket || revenueOtherTimeFromServer;

  const isLoaded = displayData !== undefined;

  return (
    <Card className="col-span-2">
      <CardHeader>
        <CardTitle>Revenue Over Time</CardTitle>
        <CardDescription>Monthly invoiced amount</CardDescription>
      </CardHeader>
      {isLoaded ? <LoadedContent data={displayData} /> : <LoadingContent />}
    </Card>
  );
};

export { ChartCardRevenueOverTime };
