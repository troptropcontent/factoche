import { DollarSign } from "lucide-react";
import { KpiCard } from "./kpi-card";
import { Api } from "@/lib/openapi-fetch-query-client";
import { useChannelSubscription } from "@/hooks/use-channel-subscription";
import { useState } from "react";
import { useTranslation } from "react-i18next";
import { KpiCardLoading } from "./kpi-card-loading";

const KpiCardTotalRevenue = ({ companyId }: { companyId: number }) => {
  const [ytdRevenuesFromWebsocket, setYtdRevenuesFromWebsocket] = useState<
    | {
        ytdRevenueForThisYear: number;
        ytdRevenueForLastYear: number;
      }
    | undefined
  >(undefined);

  const isSocketConnected = useChannelSubscription(
    `NotificationsChannel`,
    (data) => {
      if (data.type === "KpiTotalRevenueGenerated") {
        console.log("Data received : ", data.data);
        setYtdRevenuesFromWebsocket({
          ytdRevenueForLastYear: Number(data.data.ytd_revenue_for_last_year),
          ytdRevenueForThisYear: Number(data.data.ytd_revenue_for_this_year),
        });
      }
    }
  );

  const { t } = useTranslation();

  const { data: ytdRevenuesFromServer } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/dashboard",
    { params: { path: { company_id: companyId } } },
    {
      select: ({ result }) => ({
        ytdRevenueForThisYear: Number(result.kpis.ytd_total_revenues.this_year),
        ytdRevenueForLastYear: Number(result.kpis.ytd_total_revenues.last_year),
      }),
      enabled: isSocketConnected,
    }
  );

  // Use websocket data if available, otherwise fall back to query data
  const displayData = ytdRevenuesFromWebsocket || ytdRevenuesFromServer;

  if (isSocketConnected == false || displayData === undefined) {
    return <KpiCardLoading />;
  }

  return (
    <KpiCard.Root>
      <KpiCard.Header>
        <KpiCard.Title>
          {t("pages.companies.dashboard.kpi_cards.ytd_revenues.title")}
        </KpiCard.Title>
        <KpiCard.Icon>
          <DollarSign />
        </KpiCard.Icon>
      </KpiCard.Header>
      <KpiCard.Content>
        <KpiCard.MainInfo>
          {t("common.number_in_currency", {
            amount: displayData.ytdRevenueForThisYear,
          })}
        </KpiCard.MainInfo>
        {displayData.ytdRevenueForLastYear > 0 && (
          <KpiCard.SecondaryInfo>
            {t(
              "pages.companies.dashboard.kpi_cards.ytd_revenues.secondary_info",
              {
                percentage: t("common.number_in_percentage", {
                  amount:
                    ((displayData.ytdRevenueForThisYear -
                      displayData.ytdRevenueForLastYear) /
                      displayData.ytdRevenueForLastYear) *
                    100,
                }),
              }
            )}
          </KpiCard.SecondaryInfo>
        )}
      </KpiCard.Content>
    </KpiCard.Root>
  );
};

export { KpiCardTotalRevenue };
