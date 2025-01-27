import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useTranslation } from "react-i18next";

export function ClientInfo({
  client,
}: {
  client: { name: string; phone: string; email: string };
}) {
  const { t } = useTranslation();
  return (
    <Card className="mb-6">
      <CardHeader>
        <CardTitle>
          {t("pages.companies.projects.show.client_info.title")}
        </CardTitle>
      </CardHeader>
      <CardContent>
        <p className="font-semibold">{client.name}</p>
        <p>{client.phone}</p>
        <p>{client.email}</p>
      </CardContent>
    </Card>
  );
}
