import Dashboard from "@/components/pages/companies/dashboard/dashboard";
import { Layout } from "@/components/pages/companies/layout";
import { createFileRoute } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";

export const Route = createFileRoute("/_authenticated/companies/$companyId/")({
  component: RouteComponent,
});

function RouteComponent() {
  const { companyId } = Route.useParams();
  const { t } = useTranslation();
  return (
    <Layout.Root>
      <Layout.Header>
        <h1 className="text-xl font-semibold">
          {t("pages.companies.show.title")}
        </h1>
      </Layout.Header>
      <Layout.Content>
        <Dashboard companyId={Number(companyId)} />
      </Layout.Content>
    </Layout.Root>
  );
}
