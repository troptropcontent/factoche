import { CompletionSnapshotForm } from "@/components/pages/companies/completion-snapshot/completion-snapshot-form";
import { ProjectInfo } from "@/components/pages/companies/completion-snapshot/project-info";
import { Layout } from "@/components/pages/companies/layout";
import { Card, CardContent } from "@/components/ui/card";
import { Api } from "@/lib/openapi-fetch-query-client";
import { createFileRoute } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/projects/$projectId/completion_snapshots/new"
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
        if (
          projectData.result.last_version.completion_snapshots[0] == undefined
        ) {
          return { projectData, lastCompletionSnapshotData: undefined };
        }

        const lastCompletionSnapshotData = await queryClient.ensureQueryData(
          Api.queryOptions(
            "get",
            "/api/v1/organization/completion_snapshots/{id}",
            {
              params: {
                path: {
                  id: projectData.result.last_version.completion_snapshots[0]
                    .id,
                },
              },
            }
          )
        );

        return { projectData, lastCompletionSnapshotData };
      }),
});

function RouteComponent() {
  const loaderData = Route.useLoaderData();
  const { companyId, projectId } = Route.useParams();
  const { t } = useTranslation();
  return (
    <Layout.Root>
      <Layout.Header>
        <div className="flex flex-col">
          <h1 className="text-3xl font-bold">
            {t("pages.companies.completion_snapshot.form.title")}
          </h1>
        </div>
      </Layout.Header>
      <Layout.Content>
        <ProjectInfo
          projectData={loaderData.projectData.result}
          lastCompletionSnapshotData={
            loaderData.lastCompletionSnapshotData?.result
          }
        />
        <Card>
          <CardContent className="pt-6 space-y-6">
            <CompletionSnapshotForm
              companyId={Number(companyId)}
              projectId={Number(projectId)}
              itemGroups={
                loaderData.projectData.result.last_version.item_groups
              }
              previousCompletionSnapshot={
                loaderData.lastCompletionSnapshotData?.result
              }
            />
          </CardContent>
        </Card>
      </Layout.Content>
    </Layout.Root>
  );
}
