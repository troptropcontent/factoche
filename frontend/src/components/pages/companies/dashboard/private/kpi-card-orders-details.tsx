import { BarChart3 } from "lucide-react";
import { KpiCard } from "./kpi-card";
import { Api } from "@/lib/openapi-fetch-query-client";
import { useChannelSubscription } from "@/hooks/use-channel-subscription";
import { useState } from "react";
import { useTranslation } from "react-i18next";
import { KpiCardLoading } from "./kpi-card-loading";

type OrderDetailsWebsocket = {
  type: "KpiOrdersDetailsGenerated";
  data: {
    completed_orders_count: number;
    not_completed_orders_count: number;
  };
};
const KpiCardOrdersDetails = ({ companyId }: { companyId: number }) => {
  const [ordersDetailsFromWebsocket, setOrdersDetailsFromWebsocket] = useState<
    | {
        completed_orders_count: number;
        not_completed_orders_count: number;
      }
    | undefined
  >(undefined);

  const isSocketConnected = useChannelSubscription<OrderDetailsWebsocket>(
    `NotificationsChannel`,
    ({ data, type }) => {
      if (type === "KpiOrdersDetailsGenerated") {
        console.log("Data received : ", data);
        setOrdersDetailsFromWebsocket(data);
      }
    }
  );

  const { t } = useTranslation();

  const { data: ordersDetailsFromServer } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/dashboard",
    { params: { path: { company_id: companyId } } },
    {
      select: ({
        result: {
          kpis: { orders_details },
        },
      }) => orders_details,
      enabled: isSocketConnected,
    }
  );

  // Use websocket data if available, otherwise fall back to query data
  const displayData = ordersDetailsFromWebsocket || ordersDetailsFromServer;

  if (isSocketConnected == false || displayData === undefined) {
    return <KpiCardLoading />;
  }

  return (
    <KpiCard.Root>
      <KpiCard.Header>
        <KpiCard.Title>
          {t("pages.companies.dashboard.kpi_cards.orders_details.title")}
        </KpiCard.Title>
        <KpiCard.Icon>
          <BarChart3 />
        </KpiCard.Icon>
      </KpiCard.Header>
      <KpiCard.Content>
        <KpiCard.MainInfo>
          {t("pages.companies.dashboard.kpi_cards.orders_details.main_info", {
            count: displayData.not_completed_orders_count,
          })}
        </KpiCard.MainInfo>
        <KpiCard.SecondaryInfo>
          {t(
            "pages.companies.dashboard.kpi_cards.orders_details.secondary_info",
            {
              count: displayData.completed_orders_count,
            }
          )}
        </KpiCard.SecondaryInfo>
      </KpiCard.Content>
    </KpiCard.Root>
  );
};

export { KpiCardOrdersDetails };
