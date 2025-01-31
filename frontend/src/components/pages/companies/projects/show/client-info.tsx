import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Trans, useTranslation } from "react-i18next";

export function ClientInfo({
  client,
}: {
  client: { name: string; phone: string; email: string };
}) {
  const { t } = useTranslation();
  return (
    <Card className="mt-6">
      <CardHeader>
        <CardTitle>
          {t("pages.companies.projects.show.client_info.title")}
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-3">
        <p>
          <Trans
            i18nKey="pages.companies.projects.show.client_info.name"
            values={{ name: client.name }}
          />
        </p>
        <p>
          <Trans
            i18nKey="pages.companies.projects.show.client_info.phone"
            values={{ phone: client.phone }}
          />
        </p>
        <p>
          <Trans
            i18nKey="pages.companies.projects.show.client_info.email"
            values={{ email: client.email }}
          />
        </p>
      </CardContent>
    </Card>
  );
}
