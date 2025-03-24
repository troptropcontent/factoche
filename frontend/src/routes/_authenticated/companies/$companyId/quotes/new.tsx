import { Layout } from "@/components/pages/companies/layout";
import { useTranslation } from "react-i18next";
import { createFileRoute } from "@tanstack/react-router";
import { ProjectForm } from "@/components/pages/companies/projects/form/project-form";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/quotes/new"
)({
  component: RouteComponent,
});

function RouteComponent() {
  const { t } = useTranslation();
  const { companyId } = Route.useParams();

  return (
    <Layout.Root>
      <Layout.Header>
        <h1 className="text-3xl font-bold">
          {t("pages.companies.quotes.new.title")}
        </h1>
      </Layout.Header>
      <Layout.Content>
        <ProjectForm companyId={companyId} />
      </Layout.Content>
    </Layout.Root>
  );
}
