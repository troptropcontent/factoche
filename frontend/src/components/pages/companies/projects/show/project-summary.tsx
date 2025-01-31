import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Api } from "@/lib/openapi-fetch-query-client";
import { Trans, useTranslation } from "react-i18next";

export function ProjectSummary({
  routeParams: { companyId, projectId },
}: {
  routeParams: { companyId: number; projectId: number };
}) {
  const { t } = useTranslation();
  const { data, isLoading } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/projects/{id}",
    {
      params: {
        path: { company_id: Number(companyId), id: Number(projectId) },
      },
    }
  );

  if (isLoading || data == undefined) {
    return null;
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>
          {t("pages.companies.projects.show.project_summary.title")}
        </CardTitle>
      </CardHeader>
      <CardContent>
        <p>
          <Trans
            i18nKey="pages.companies.projects.show.project_summary.name"
            values={{ name: data.result.name }}
          />
        </p>
      </CardContent>
    </Card>
  );
}
