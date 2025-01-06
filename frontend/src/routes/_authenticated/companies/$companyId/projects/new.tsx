import { ClientForm } from "@/components/pages/companies/clients/client-form";
import { Layout } from "@/components/pages/companies/layout";
import { ProjectForm } from "@/components/pages/companies/projects/project-form";
import { getCompanyClientsQueryOptions } from "@/queries/organization/clients/getCompanyClientsQueryOptions";
import { createFileRoute } from "@tanstack/react-router";
import { ReactElement, useState } from "react";
import { useTranslation } from "react-i18next";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/projects/new"
)({
  component: RouteComponent,
  loader: ({ context: { queryClient }, params: { companyId } }) =>
    queryClient.ensureQueryData(getCompanyClientsQueryOptions(companyId)),
});

const steps: Array<{ type: string; component: ReactElement }> = [
  {
    type: "base_info",
    component: <div>Project Details</div>,
  },
  {
    type: "project_composition",
    component: <div>Project Composition</div>,
  },
  {
    type: "confirmation",
    component: <div>Project confirmation</div>,
  },
];

function RouteComponent() {
  const { t } = useTranslation();
  const { data: clients } = Route.useLoaderData();

  return (
    <Layout.Root>
      <Layout.Header>
        <h1 className="text-3xl font-bold">
          {t("pages.companies.projects.new.title")}
        </h1>
      </Layout.Header>
      <Layout.Content>
        <ProjectForm
          clients={clients.map((client) => {
            return { id: client.id, name: client.name };
          })}
        />
      </Layout.Content>
    </Layout.Root>
  );
}
