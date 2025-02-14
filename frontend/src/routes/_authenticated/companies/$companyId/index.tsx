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
        <h1>{t("pages.companies.show.title")}</h1>
      </Layout.Header>
      <Layout.Content>
        <p>{t("pages.companies.show.description", { companyId })}</p>
      </Layout.Content>
    </Layout.Root>
  );
}
