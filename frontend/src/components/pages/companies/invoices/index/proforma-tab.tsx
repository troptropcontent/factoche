import { TabsContent } from "@/components/ui/tabs";

import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { useTranslation } from "react-i18next";
import { TabTrigger } from "./private/tab-trigger";
import { Api } from "@/lib/openapi-fetch-query-client";
import { ProformasTable } from "./private/proformas-table";

const TAB_VALUE = "proforma" as const;

const Trigger = ({ companyId }: { companyId: string }) => {
  const { data: proformaData } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/proformas",
    { params: { path: { company_id: Number(companyId) } } }
  );

  return <TabTrigger documents={proformaData?.results} tab={TAB_VALUE} />;
};

const Content = ({ companyId }: { companyId: string }) => {
  const { data: proformaData } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/proformas",
    { params: { path: { company_id: Number(companyId) } } }
  );
  const { t } = useTranslation();
  return (
    <TabsContent value={TAB_VALUE}>
      <Card>
        <CardHeader>
          <CardTitle>
            {t("pages.companies.projects.invoices.index.tabs.proforma.title")}
          </CardTitle>
          <CardDescription>
            {t(
              "pages.companies.projects.invoices.index.tabs.proforma.description"
            )}
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <ProformasTable
              companyId={companyId}
              documentsData={
                proformaData
                  ? {
                      documents: proformaData.results,
                      orders: proformaData.meta.orders,
                      orderVersions: proformaData.meta.order_versions,
                    }
                  : undefined
              }
            />
          </div>
        </CardContent>
      </Card>
    </TabsContent>
  );
};

const ProformaTab = { Content, Trigger };

export { ProformaTab };
