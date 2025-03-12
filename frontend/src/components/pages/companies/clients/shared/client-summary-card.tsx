import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Api } from "@/lib/openapi-fetch-query-client";
import { Trans, useTranslation } from "react-i18next";

export function ClientSummaryCard({
  clientId,
  name,
  phone,
  email,
}:
  | { clientId: number; name?: never; phone?: never; email?: never }
  | { clientId?: never; name: string; phone: string; email: string }) {
  const { data } = Api.useQuery(
    "get",
    "/api/v1/organization/clients/{id}",
    {
      params: { path: { id: clientId } },
    },
    {
      enabled: clientId !== undefined,
    }
  );

  const { t } = useTranslation();

  if (clientId !== undefined && data == undefined) {
    return null;
  }

  const clientInfo =
    clientId !== undefined ? data!.result : { name, phone, email };

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
            values={{ name: clientInfo.name }}
          />
        </p>
        <p>
          <Trans
            i18nKey="pages.companies.projects.show.client_info.phone"
            values={{ phone: clientInfo.phone }}
          />
        </p>
        <p>
          <Trans
            i18nKey="pages.companies.projects.show.client_info.email"
            values={{ email: clientInfo.email }}
          />
        </p>
      </CardContent>
    </Card>
  );
}
