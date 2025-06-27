import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { Api } from "@/lib/openapi-fetch-query-client";
import { Link } from "@tanstack/react-router";
import { Eye } from "lucide-react";
import { ReactNode } from "react";
import { useTranslation } from "react-i18next";

type OrderSummaryCardProps =
  | {
      isLoading: true;
      companyId?: never;
      orderId?: never;
      name?: never;
      version_number?: never;
      version_date?: never;
    }
  | {
      isLoading?: false;
      companyId: string;
      orderId: number;
      name?: string;
      version_number?: number;
      version_date?: string;
    };

const BaseComponent = ({
  link,
  name,
  version,
}: {
  link: ReactNode;
  name: ReactNode;
  version: ReactNode;
}) => {
  const { t } = useTranslation();

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex justify-between">
          {t("pages.companies.projects.show.project_summary.title")}
          {link}
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-3">
        <div className="flex items-center gap-2">
          <strong>
            {t("pages.companies.orders.shared.summary_card.name")}
          </strong>
          {name}
        </div>
        <div className="flex items-center gap-2">
          <strong>
            {t("pages.companies.orders.shared.summary_card.version")}
          </strong>
          {version}
        </div>
      </CardContent>
    </Card>
  );
};

const Loading = () => {
  return (
    <BaseComponent
      link={<Skeleton className="h-4 w-8" />}
      name={<Skeleton className="h-4 flex-grow" />}
      version={<Skeleton className="h-4 flex-grow" />}
    />
  );
};

const Loaded = ({
  companyId,
  orderId,
  name,
  version_date,
  version_number,
}: Required<Omit<OrderSummaryCardProps, "isLoading">>) => {
  const { t } = useTranslation();

  return (
    <BaseComponent
      link={
        <Link
          to={"/companies/$companyId/orders/$orderId"}
          params={{
            companyId: companyId,
            orderId: orderId.toString(),
          }}
        >
          <Eye className="mr-2 h-4 w-4" />
        </Link>
      }
      name={name}
      version={t("pages.companies.orders.shared.summary_card.version_label", {
        number: version_number,
        createdAt: Date.parse(version_date),
      })}
    />
  );
};

export function OrderSummaryCard({
  isLoading,
  companyId,
  orderId,
  name,
  version_date,
  version_number,
}: OrderSummaryCardProps) {
  const shouldFetchOrderData =
    name !== undefined &&
    version_date !== undefined &&
    version_number !== undefined;

  const { data } = Api.useQuery(
    "get",
    "/api/v1/organization/orders/{id}",
    {
      params: {
        path: { id: Number(orderId) },
      },
    },
    {
      enabled: shouldFetchOrderData,
    }
  );

  if (isLoading || (shouldFetchOrderData && data == undefined)) {
    return <Loading />;
  }

  const orderData = {
    name: name || data!.result.name,
    version_number: version_number || data!.result.last_version.number,
    version_date: version_date || data!.result.last_version.created_at,
  };

  return <Loaded companyId={companyId} orderId={orderId} {...orderData} />;
}
