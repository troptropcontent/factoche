import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Api } from "@/lib/openapi-fetch-query-client";
import { Trans, useTranslation } from "react-i18next";

export function ClientSummaryCard({ clientId }: { clientId: number }) {
  const { data, isLoading } = Api.useQuery(
    "get",
    "/api/v1/organization/clients/{id}",
    {
      params: { path: { id: clientId } },
    }
  );

  const { t } = useTranslation();

  if (isLoading || data == undefined) {
    return null;
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>
          {t("pages.companies.projects.show.client_info.title")}
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-3">
        <p>
          <Trans
            i18nKey="pages.companies.projects.show.client_info.name"
            values={{ name: data.result.name }}
          />
        </p>
        <p>
          <Trans
            i18nKey="pages.companies.projects.show.client_info.phone"
            values={{ phone: data.result.phone }}
          />
        </p>
        <p>
          <Trans
            i18nKey="pages.companies.projects.show.client_info.email"
            values={{ email: data.result.email }}
          />
        </p>
      </CardContent>
    </Card>
  );
}
