import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
} from "@/components/ui/chart";
import { useChannelSubscription } from "@/hooks/use-channel-subscription";
import { Api } from "@/lib/openapi-fetch-query-client";
import { useState } from "react";
import {
  Bar,
  BarChart,
  CartesianGrid,
  ResponsiveContainer,
  XAxis,
  YAxis,
} from "recharts";
import { buildChartCardRevenueByClientData } from "./util";
import { useTranslation } from "react-i18next";

type RevenueByClientWebsocket = {
  type: "GraphDataRevenueByClientGenerated";
  data: {
    client_id: number;
    revenue: string;
  }[];
};

const useRevenueByClientFromApiResponseOrWebsocket = (companyId: number) => {
  const [revenueByClientFromWebsocket, setRevenueByClientFromWebsocket] =
    useState<RevenueByClientWebsocket["data"] | undefined>(undefined);

  const isSocketConnected = useChannelSubscription<RevenueByClientWebsocket>(
    `NotificationsChannel`,
    ({ data, type }) => {
      if (type === "GraphDataRevenueByClientGenerated") {
        setRevenueByClientFromWebsocket(data);
      }
    }
  );

  const { data: revenueByClientFromApiResponse } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/dashboard",
    { params: { path: { company_id: companyId } } },
    {
      select: ({
        result: {
          charts_data: { revenue_by_client },
        },
      }) => revenue_by_client,
      enabled: isSocketConnected,
    }
  );

  // Use websocket data if available, otherwise fall back to query data
  const displayData =
    revenueByClientFromWebsocket || revenueByClientFromApiResponse;

  return displayData;
};

const ChartCardRevenueByClient = ({ companyId }: { companyId: number }) => {
  const revenueByClient =
    useRevenueByClientFromApiResponseOrWebsocket(companyId);
  const { data: clients } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/clients",
    { params: { path: { company_id: companyId } } }
  );

  const { t } = useTranslation();

  const isDataLoaded = clients != undefined && revenueByClient != undefined;

  const data = isDataLoaded
    ? buildChartCardRevenueByClientData(revenueByClient, clients)
    : [];

  return (
    <Card>
      <CardHeader>
        <CardTitle>
          {t("pages.companies.dashboard.charts.revenue_by_client.title")}
        </CardTitle>
        <CardDescription>
          {t("pages.companies.dashboard.charts.revenue_by_client.description")}
        </CardDescription>
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
              data={data}
              layout="vertical"
              margin={{ top: 5, right: 30, left: 20, bottom: 5 }}
            >
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis
                type="number"
                tickFormatter={(value) => `${value / 1000}k€`}
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
  );
};

export { ChartCardRevenueByClient };
