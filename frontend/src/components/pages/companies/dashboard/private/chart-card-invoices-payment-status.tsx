import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";

import { useChannelSubscription } from "@/hooks/use-channel-subscription";
import { Api } from "@/lib/openapi-fetch-query-client";
import { useState } from "react";
import { Cell, Pie, PieChart, ResponsiveContainer, Tooltip } from "recharts";

import { useTranslation } from "react-i18next";
import { Skeleton } from "@/components/ui/skeleton";

const PaymentStatusColors = {
  paid: "#10b981",
  pending: "#f59e0b",
  overdue: "#ef4444",
} as const;

type InvoicePaymentStatusDistributionFromWebsocketType = {
  type: "InvoiceStatusGraphDataGenerated";
  data: { pending: string; overdue: string; paid: string };
};

const useInvoicePaymentStatusDistributionFromApiResponseOrWebsocket = (
  companyId: number
) => {
  const [
    invoicePaymentStatusDistributionFromWebsocket,
    setInvoicePaymentStatusDistributionFromWebsocket,
  ] = useState<
    InvoicePaymentStatusDistributionFromWebsocketType["data"] | undefined
  >(undefined);

  const isSocketConnected =
    useChannelSubscription<InvoicePaymentStatusDistributionFromWebsocketType>(
      `NotificationsChannel`,
      ({ data, type }) => {
        if (type === "InvoiceStatusGraphDataGenerated") {
          console.log("DATA RECEIVED FROM WEBSOCKET, ", data);
          setInvoicePaymentStatusDistributionFromWebsocket(data);
        }
      }
    );

  const { data: invoicePaymentStatusDistributionFromApiResponse } =
    Api.useQuery(
      "get",
      "/api/v1/organization/companies/{company_id}/dashboard",
      { params: { path: { company_id: companyId } } },
      {
        select: ({
          result: {
            charts_data: { invoice_payment_status_distribution },
          },
        }) => invoice_payment_status_distribution,
        enabled: isSocketConnected,
      }
    );

  // Use websocket data if available, otherwise fall back to query data
  const displayData =
    invoicePaymentStatusDistributionFromWebsocket ||
    invoicePaymentStatusDistributionFromApiResponse;

  return displayData;
};

const ChartCardInvoicesPaymentStatus = ({
  companyId,
}: {
  companyId: number;
}) => {
  const { t } = useTranslation();
  const invoicePaymentStatusDistribution =
    useInvoicePaymentStatusDistributionFromApiResponseOrWebsocket(companyId);

  const chartData = invoicePaymentStatusDistribution
    ? Object.entries(invoicePaymentStatusDistribution).map(([key, value]) => ({
        name: key,
        value: Number(value) * 100,
        color: PaymentStatusColors[key as keyof typeof PaymentStatusColors],
      }))
    : undefined;

  return (
    <Card className="col-span-2 lg:col-span-1 flex flex-col">
      <CardHeader>
        <CardTitle>
          {t(
            "pages.companies.dashboard.charts.invoice_payment_status_distribution.title"
          )}
        </CardTitle>
        <CardDescription>
          {t(
            "pages.companies.dashboard.charts.invoice_payment_status_distribution.description"
          )}
        </CardDescription>
      </CardHeader>
      <CardContent className="flex-grow flex items-center">
        {chartData ? (
          <div>
            <div className="flex justify-center">
              <ResponsiveContainer width="100%" height={250}>
                <PieChart>
                  <Pie
                    data={chartData}
                    cx="50%"
                    cy="50%"
                    innerRadius={60}
                    outerRadius={80}
                    paddingAngle={5}
                    dataKey="value"
                  >
                    {chartData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip
                    formatter={(value, name) => [
                      t("common.number_in_percentage", {
                        amount: value,
                      }),
                      t(
                        `pages.companies.projects.invoices.index.tabs.table.columns.payment_status.${name}`
                      ),
                    ]}
                  />
                </PieChart>
              </ResponsiveContainer>
            </div>
            <div className="flex justify-center gap-4 mt-2">
              {chartData.map((status, index) => (
                <div key={index} className="flex items-center gap-1">
                  <div
                    className="w-3 h-3 rounded-full"
                    style={{ backgroundColor: status.color }}
                  ></div>
                  <span className="text-sm">
                    {t(
                      `pages.companies.projects.invoices.index.tabs.table.columns.payment_status.${status.name}`
                    )}{" "}
                    {`(${t("common.number_in_percentage", {
                      amount: status.value,
                    })})`}
                  </span>
                </div>
              ))}
            </div>
          </div>
        ) : (
          <Skeleton className="h-full w-full" />
        )}
      </CardContent>
    </Card>
  );
};

export { ChartCardInvoicesPaymentStatus };
