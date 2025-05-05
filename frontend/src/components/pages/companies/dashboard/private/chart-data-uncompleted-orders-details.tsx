import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import { Skeleton } from "@/components/ui/skeleton";
import { useChannelSubscription } from "@/hooks/use-channel-subscription";
import { Api } from "@/lib/openapi-fetch-query-client";
import { paths } from "@/lib/openapi-fetch-schemas";
import { useState } from "react";
import { useTranslation } from "react-i18next";

type UncompletedOrdersDetails =
  paths["/api/v1/organization/companies/{company_id}/dashboard"]["get"]["responses"]["200"]["content"]["application/json"]["result"]["charts_data"]["order_completion_percentages"];

const useUncompletedOrdersDetailsFromApiResponseOrWebsocket = (
  companyId: number
) => {
  const [
    uncompletedOrdersDetailsFromWebsocket,
    setUncompletedOrdersDetailsFromWebsocket,
  ] = useState<UncompletedOrdersDetails | undefined>(undefined);

  const isSocketConnected = useChannelSubscription<{
    type: "GraphDataRevenueByClientGenerated";
    data: UncompletedOrdersDetails;
  }>(`NotificationsChannel`, ({ data, type }) => {
    if (type === "GraphDataRevenueByClientGenerated") {
      setUncompletedOrdersDetailsFromWebsocket(data);
    }
  });

  const { data: uncompletedOrdersDetailsFromApieResponse = [] } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/dashboard",
    { params: { path: { company_id: companyId } } },
    {
      select: ({
        result: {
          charts_data: { order_completion_percentages },
        },
      }) => order_completion_percentages,
      enabled: isSocketConnected,
    }
  );

  // Use websocket data if available, otherwise fall back to query data

  return (
    uncompletedOrdersDetailsFromWebsocket ||
    uncompletedOrdersDetailsFromApieResponse
  );
};

const ChartDataUncompletedOrdersDetails = ({
  companyId,
}: {
  companyId: number;
}) => {
  const { t } = useTranslation();
  const data = useUncompletedOrdersDetailsFromApiResponseOrWebsocket(companyId);

  return (
    <Card className="col-span-full">
      <CardHeader>
        <CardTitle>
          {t("pages.companies.dashboard.charts.major_orders_details.title")}
        </CardTitle>
        <CardDescription>
          {t(
            "pages.companies.dashboard.charts.major_orders_details.description"
          )}
        </CardDescription>
      </CardHeader>
      <CardContent>
        {data === undefined ? (
          <Skeleton className="h-4 w-full" />
        ) : (
          <div className="space-y-4">
            {data.map((order) => (
              <div key={order.name} className="space-y-2">
                <div className="flex items-center justify-between">
                  <span className="font-medium">{order.name}</span>
                  <span className="text-sm text-muted-foreground">
                    {t("common.number_in_currency", {
                      amount: order.invoiced_total_amount,
                    })}{" "}
                    /{" "}
                    {t("common.number_in_currency", {
                      amount: order.order_total_amount,
                    })}
                  </span>
                </div>
                <div className="flex items-center gap-2">
                  <Progress
                    value={Number(order.completion_percentage) * 100}
                    className="h-2"
                  />
                  <span className="text-sm font-medium w-10">
                    {t("common.number_in_percentage", {
                      amount: Number(order.completion_percentage) * 100,
                    })}
                  </span>
                </div>
              </div>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  );
};

export { ChartDataUncompletedOrdersDetails };
