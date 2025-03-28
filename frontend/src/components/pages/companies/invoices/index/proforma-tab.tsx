import { TabsContent } from "@/components/ui/tabs";

import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { useTranslation } from "react-i18next";
import { useProformaQuery } from "../private/hooks";
import { DocumentTable } from "./private/document-table";
import { TabTrigger } from "./private/tab-trigger";

const TAB_VALUE = "proforma" as const;

const Trigger = ({ companyId }: { companyId: string }) => {
  const { data: invoicesData } = useProformaQuery(companyId);
  return <TabTrigger documents={invoicesData?.results} tab={TAB_VALUE} />;
};

const Content = ({ companyId }: { companyId: string }) => {
  const { data: invoicesData } = useProformaQuery(companyId);
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
            <DocumentTable
              documentsData={
                invoicesData
                  ? {
                      invoices: invoicesData.results,
                      orders: invoicesData.meta.orders,
                      orderVersions: invoicesData.meta.order_versions,
                    }
                  : undefined
              }
              tab={TAB_VALUE}
            />
          </div>
        </CardContent>
      </Card>
    </TabsContent>
  );
};

const ProformaTab = { Content, Trigger };

export { ProformaTab };
