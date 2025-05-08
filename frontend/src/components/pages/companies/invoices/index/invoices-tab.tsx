import { TabsContent } from "@/components/ui/tabs";

import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { useTranslation } from "react-i18next";
import { useInvoicesQuery } from "../private/hooks";
import { InvoicesTable } from "./private/invoices-table";
import { TabTrigger } from "./private/tab-trigger";
import { Api } from "@/lib/openapi-fetch-query-client";

const TAB_VALUE = "invoices" as const;

const Trigger = ({ companyId }: { companyId: string }) => {
  const { data: invoicesData } = useInvoicesQuery(companyId);
  return <TabTrigger documents={invoicesData?.results} tab={TAB_VALUE} />;
};

const Content = ({ companyId }: { companyId: string }) => {
  const { data: invoicesData } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/invoices",
    {
      params: {
        path: { company_id: Number(companyId) },
      },
    }
  );

  const { t } = useTranslation();
  return (
    <TabsContent value={TAB_VALUE}>
      <Card>
        <CardHeader>
          <CardTitle>
            {t("pages.companies.projects.invoices.index.tabs.invoices.title")}
          </CardTitle>
          <CardDescription>
            {t(
              "pages.companies.projects.invoices.index.tabs.invoices.description"
            )}
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <InvoicesTable
              companyId={companyId}
              documentsData={
                invoicesData
                  ? {
                      documents: invoicesData.results,
                      orders: invoicesData.meta.orders,
                      orderVersions: invoicesData.meta.order_versions,
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

const InvoicesTab = { Content, Trigger };

export { InvoicesTab };
