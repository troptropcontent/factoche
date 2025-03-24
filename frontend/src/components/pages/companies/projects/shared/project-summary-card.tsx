import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Api } from "@/lib/openapi-fetch-query-client";
import { Trans, useTranslation } from "react-i18next";

type ProjectSummaryCardProps =
  | {
      orderId: number;
      name?: never;
      version_number?: never;
      version_date?: never;
    }
  | {
      orderId?: never;
      name: string;
      version_number: number;
      version_date: string;
    };

export function ProjectSummaryCard({
  name,
  orderId,
  version_date,
  version_number,
}: ProjectSummaryCardProps) {
  const { t } = useTranslation();
  const { data } = Api.useQuery(
    "get",
    "/api/v1/organization/orders/{id}",
    {
      params: {
        path: { id: Number(orderId) },
      },
    },
    {
      enabled: orderId !== undefined,
    }
  );

  if (orderId !== undefined && data == undefined) {
    return null;
  }

  const projectData =
    orderId !== undefined
      ? {
          name: data!.result.name,
          version_number: data!.result.last_version.number,
          version_date: data!.result.last_version.created_at,
        }
      : { name, version_number, version_date };

  return (
    <Card>
      <CardHeader>
        <CardTitle>
          {t("pages.companies.projects.show.project_summary.title")}
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-3">
        <p>
          <Trans
            i18nKey="pages.companies.projects.show.project_summary.name"
            values={{ name: projectData.name }}
          />
        </p>
        <p>
          <Trans
            i18nKey="pages.companies.projects.show.project_summary.version_label"
            values={{
              number: projectData.version_number,
              createdAt: Date.parse(projectData.version_date),
            }}
          />
        </p>
      </CardContent>
    </Card>
  );
}
