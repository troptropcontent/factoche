import { Layout } from "@/components/pages/companies/layout";
import { ProjectShowContent } from "@/components/pages/companies/projects/show/project-show-content";
import { Api } from "@/lib/openapi-fetch-query-client";
import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/projects/$projectId/"
)({
  component: RouteComponent,
  loader: ({ context: { queryClient }, params: { companyId, projectId } }) =>
    queryClient
      .ensureQueryData(
        Api.queryOptions(
          "get",
          "/api/v1/organization/companies/{company_id}/projects/{id}",
          {
            params: {
              path: { company_id: Number(companyId), id: Number(projectId) },
            },
          }
        )
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
                  project_id: Number(projectId),
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
  const { companyId, projectId } = Route.useParams();

  return (
    <Layout.Root>
      <Layout.Header>
        <div className="flex flex-grow justify-between items-center">
          <h1 className="text-3xl font-bold">{project.name}</h1>
        </div>
      </Layout.Header>
      <Layout.Content>
        <ProjectShowContent
          companyId={Number(companyId)}
          projectId={Number(projectId)}
          client={project.client}
          lastVersionId={project.last_version.id}
          initialVersionId={project.last_version.id}
        />
      </Layout.Content>
    </Layout.Root>
  );
}
