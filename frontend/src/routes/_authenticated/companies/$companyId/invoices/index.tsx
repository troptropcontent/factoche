import { zodValidator } from "@tanstack/zod-adapter";
import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { Tabs, TabsList } from "@/components/ui/tabs";
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

  const handleTabChange = (value: string) => {
    if (!(TABS as ReadonlyArray<string>).includes(value)) {
      throw new Error(`Invalid tab value: ${value}`);
    }
    navigate({ search: { tab: value as Tab } });
  };

  return (
    <Layout.Root>
      <Layout.Header>
        <div className="flex flex-grow justify-between items-center">
          <h1 className="text-3xl font-bold">
            {t("pages.companies.projects.invoices.index.title")}
          </h1>
        </div>
      </Layout.Header>
      <Layout.Content>
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
