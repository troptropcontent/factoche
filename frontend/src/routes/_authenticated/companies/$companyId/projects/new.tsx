import { Layout } from "@/components/pages/companies/layout";
import { ProjectForm } from "@/components/pages/companies/projects/form/project-form";
import { createFileRoute } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/projects/new"
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
          {t("pages.companies.projects.new.title")}
        </h1>
      </Layout.Header>
      <Layout.Content>
        <ProjectForm companyId={companyId} />
      </Layout.Content>
    </Layout.Root>
  );
}
