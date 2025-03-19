import { Layout } from "@/components/pages/companies/layout";
import { ProjectShowContent } from "@/components/pages/companies/projects/show/project-show-content";
import { Api } from "@/lib/openapi-fetch-query-client";
import { createFileRoute } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/orders/$orderId/"
)({
  component: RouteComponent,
  loader: ({ context: { queryClient }, params: { companyId, orderId } }) =>
    queryClient
      .ensureQueryData(
        Api.queryOptions("get", "/api/v1/organization/orders/{id}", {
          params: {
            path: { id: Number(orderId) },
          },
        })
      )
      .then(async (projectData) => {
        await queryClient.ensureQueryData(
          Api.queryOptions(
            "get",
            "/api/v1/organization/companies/{company_id}/projects/{project_id}/versions/{id}",
            {
              params: {
                path: {
                  company_id: Number(companyId),
                  project_id: Number(orderId),
                  id: projectData.result.last_version.id,
                },
              },
            }
          )
        );

        return projectData;
      }),
});

function RouteComponent() {
  const { result: project } = Route.useLoaderData();
  const { companyId, orderId } = Route.useParams();
  const { t } = useTranslation();
  return (
    <Layout.Root>
      <Layout.Header>
        <h1 className="text-3xl font-bold">
          {t("pages.companies.projects.show.title")}
        </h1>
      </Layout.Header>
      <Layout.Content>
        <ProjectShowContent
          companyId={Number(companyId)}
          orderId={Number(orderId)}
          client={project.client}
          lastVersionId={project.last_version.id}
          initialVersionId={project.last_version.id}
        />
      </Layout.Content>
    </Layout.Root>
  );
}
