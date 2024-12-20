import { ClientForm } from "@/components/pages/companies/clients/client-form";
import { Layout } from "@/components/pages/companies/layout";
import { createFileRoute } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/clients/new"
)({
  component: RouteComponent,
});

function RouteComponent() {
  const { t } = useTranslation();
  return (
    <Layout.Root>
      <Layout.Header>
        <h1 className="text-3xl font-bold">
          {t("pages.companies.clients.new.title")}
        </h1>
      </Layout.Header>
      <Layout.Content>
        <ClientForm />
      </Layout.Content>
    </Layout.Root>
  );
}
