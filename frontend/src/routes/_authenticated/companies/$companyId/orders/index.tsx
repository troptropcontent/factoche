import { DraftOrdersTable } from "@/components/pages/companies/draft_orders/index/draft-orders-table";
import { Layout } from "@/components/pages/companies/layout";
import { OrdersTable } from "@/components/pages/companies/orders/index/orders-table";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { TabsContent } from "@/components/ui/tabs";
import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";

import { useTranslation } from "react-i18next";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/orders/"
)({
  component: RouteComponent,
});

function RouteComponent() {
  const { companyId } = Route.useParams();
  const { t } = useTranslation();
  const [activeTab, setActiveTab] = useState<"orders" | "draft_orders">(
    "orders"
  );

  return (
    <Layout.Root>
      <Layout.Header>
        <div className="flex flex-grow justify-between items-center">
          <h1 className="text-3xl font-bold">
            {t("pages.companies.orders.index.title")}
          </h1>
        </div>
      </Layout.Header>
      <Layout.Content>
        <div className="container mx-auto">
          <Tabs
            value={activeTab}
            onValueChange={(value) => setActiveTab(value as typeof activeTab)}
          >
            <TabsList className="grid w-full grid-cols-2">
              <TabsTrigger value="orders">
                {t("pages.companies.orders.index.tabs.posted.title")}
              </TabsTrigger>
              <TabsTrigger value="draft_orders">
                {t("pages.companies.orders.index.tabs.draft.title")}
              </TabsTrigger>
            </TabsList>

            <TabsContent value="orders" className="pt-4">
              <OrdersTable companyId={companyId} />
            </TabsContent>

            <TabsContent value="draft_orders" className="pt-4">
              <DraftOrdersTable companyId={companyId} />
            </TabsContent>
          </Tabs>
        </div>
      </Layout.Content>
    </Layout.Root>
  );
}
