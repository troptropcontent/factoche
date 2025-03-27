import { TabsContent, TabsTrigger } from "@/components/ui/tabs";

import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { useTranslation } from "react-i18next";
import { Loader } from "lucide-react";
import { useProformaQuery } from "../private/hooks";
import { Badge } from "@/components/ui/badge";
import { DocumentTable } from "./private/document-table";

const TAB_VALUE = "proforma" as const;

const Trigger = ({ companyId }: { companyId: string }) => {
  const { data: invoices } = useProformaQuery(companyId);
  const { t } = useTranslation();
  return (
    <TabsTrigger value={TAB_VALUE}>
      {t("pages.companies.projects.invoices.index.tabs.proforma.title")}
      <Badge variant="outline" className="ml-2">
        {invoices === undefined ? <Loader /> : invoices.length}
      </Badge>
    </TabsTrigger>
  );
};

const Content = ({ companyId }: { companyId: string }) => {
  const { data: invoices } = useProformaQuery(companyId);
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
            <DocumentTable documents={invoices} tab={TAB_VALUE} />
          </div>
        </CardContent>
      </Card>
    </TabsContent>
  );
};

const ProformaTab = { Content, Trigger };

export { ProformaTab };
