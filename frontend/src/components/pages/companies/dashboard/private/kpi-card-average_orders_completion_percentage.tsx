import { BarChart3 } from "lucide-react";
import { KpiCard } from "./kpi-card";
import { Api } from "@/lib/openapi-fetch-query-client";
import { useChannelSubscription } from "@/hooks/use-channel-subscription";
import { useState } from "react";
import { useTranslation } from "react-i18next";
import { KpiCardLoading } from "./kpi-card-loading";
import { Progress } from "@/components/ui/progress";

type AverageOrderCompletionPercentageWebsocket = {
  type: "KpiAverageOrderCompletionGenerated";
  data: number;
};
const KpiCardAverageOrdersCompletionPercentage = ({
  companyId,
}: {
  companyId: number;
}) => {
  const [
    averageOrdersCompletionPercentageFromWebsocket,
    setaverageOrdersCompletionPercentageFromWebsocket,
  ] = useState<number | undefined>(undefined);

  const isSocketConnected =
    useChannelSubscription<AverageOrderCompletionPercentageWebsocket>(
      `NotificationsChannel`,
      ({ data, type }) => {
        if (type === "KpiAverageOrderCompletionGenerated") {
          console.log("Data received : ", data);
          setaverageOrdersCompletionPercentageFromWebsocket(data);
        }
      }
    );

  const { t } = useTranslation();

  const { data: averageOrdersCompletionPercentageFromServer } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/dashboard",
    { params: { path: { company_id: companyId } } },
    {
      select: ({
        result: {
          kpis: { average_orders_completion_percentage },
        },
      }) => Number(average_orders_completion_percentage),
      enabled: isSocketConnected,
    }
  );

  // Use websocket data if available, otherwise fall back to query data
  const displayData =
    averageOrdersCompletionPercentageFromWebsocket ||
    averageOrdersCompletionPercentageFromServer;

  if (isSocketConnected == false || displayData === undefined) {
    return <KpiCardLoading />;
  }

  return (
    <KpiCard.Root>
      <KpiCard.Header>
        <KpiCard.Title>
          {t(
            "pages.companies.dashboard.kpi_cards.average_orders_completion.title"
          )}
        </KpiCard.Title>
        <KpiCard.Icon>
          <BarChart3 />
        </KpiCard.Icon>
      </KpiCard.Header>
      <KpiCard.Content>
        <KpiCard.MainInfo>
          {t("common.number_in_percentage", {
            amount: displayData * 100,
          })}
        </KpiCard.MainInfo>
        <KpiCard.SecondaryInfo>
          <Progress value={displayData * 100} className="mt-2" />
        </KpiCard.SecondaryInfo>
      </KpiCard.Content>
    </KpiCard.Root>
  );
};

export { KpiCardAverageOrdersCompletionPercentage };
