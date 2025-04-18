import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Api } from "@/lib/openapi-fetch-query-client";
import { Trans, useTranslation } from "react-i18next";
import { ProjectTypeKey } from "../shared/types";

export function ProjectSummary({
  routeParams: { projectId },
  type,
}: {
  routeParams: { projectId: number };
  type: ProjectTypeKey;
}) {
  const { t } = useTranslation();
  const { data, isLoading } = Api.useQuery(
    "get",
    `/api/v1/organization/${type}s/{id}`,
    {
      params: {
        path: { id: Number(projectId) },
      },
    }
  );

  if (isLoading || data == undefined) {
    return null;
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-xl">
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
