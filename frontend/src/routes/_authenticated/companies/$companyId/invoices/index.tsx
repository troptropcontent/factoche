import { zodValidator } from "@tanstack/zod-adapter";
import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Tabs, TabsList } from "@/components/ui/tabs";
import { Search, Download, Filter } from "lucide-react";
import { z } from "zod";
import { InvoicesTab } from "@/components/pages/companies/invoices/index/invoices-tab";
import { Layout } from "@/components/pages/companies/layout";
import { useTranslation } from "react-i18next";
import { ProformaTab } from "@/components/pages/companies/invoices/index/proforma-tab";
import { CreditNotesTab } from "@/components/pages/companies/invoices/index/credit-notes-tab";
import { TABS } from "@/components/pages/companies/invoices/index/shared/constants";
import { Tab } from "@/components/pages/companies/invoices/index/shared/types";

const productSearchSchema = z.object({
  tab: z.enum(TABS).default("invoices"),
});

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/invoices/"
)({
  component: RouteComponent,
  validateSearch: zodValidator(productSearchSchema),
});

function RouteComponent() {
  const { companyId } = Route.useParams();
  const searchParams = Route.useSearch();
  const activeTab = searchParams.tab;
  const navigate = useNavigate({ from: Route.fullPath });
  const { t } = useTranslation();

  // Update URL when tab changes
  const handleTabChange = (value: string) => {
    if (!(TABS as ReadonlyArray<string>).includes(value)) {
      throw new Error(`Invalid tab value: ${value}`);
    }
    navigate({ search: { tab: value as Tab } });
  };

  return (
    <Layout.Root>
      <Layout.Header>
        <h1>{t("pages.companies.show.title")}</h1>
      </Layout.Header>
      <Layout.Content>
        <Card className="mb-8">
          <CardHeader>
            <CardTitle>Recherche et filtres</CardTitle>
            <CardDescription>
              Recherchez et filtrez vos documents
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="flex flex-col sm:flex-row gap-4">
              <div className="relative flex-1">
                <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
                <Input
                  type="search"
                  placeholder="Rechercher par client ou numéro..."
                  className="pl-8"
                />
              </div>
              <div className="flex gap-2">
                <Button variant="outline" className="flex items-center gap-2">
                  <Filter className="h-4 w-4" />
                  Filtres
                </Button>
                <Button variant="outline" className="flex items-center gap-2">
                  <Download className="h-4 w-4" />
                  Exporter
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>

        <Tabs
          value={activeTab}
          onValueChange={handleTabChange}
          className="w-full"
        >
          <TabsList className="grid w-full grid-cols-3 mb-8">
            <InvoicesTab.Trigger companyId={companyId} />
            <CreditNotesTab.Trigger companyId={companyId} />
            <ProformaTab.Trigger companyId={companyId} />
          </TabsList>

          <InvoicesTab.Content companyId={companyId} />
          <CreditNotesTab.Content companyId={companyId} />
          <ProformaTab.Content companyId={companyId} />
        </Tabs>
      </Layout.Content>
    </Layout.Root>
  );
}
