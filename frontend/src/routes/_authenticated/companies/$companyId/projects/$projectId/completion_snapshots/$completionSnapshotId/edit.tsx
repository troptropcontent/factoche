import { CompletionSnapshotForm } from "@/components/pages/companies/completion-snapshot/completion-snapshot-form";
import { ProjectInfo } from "@/components/pages/companies/completion-snapshot/project-info";
import { Layout } from "@/components/pages/companies/layout";
import { Card, CardContent } from "@/components/ui/card";
import { Api } from "@/lib/openapi-fetch-query-client";
import { createFileRoute } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/projects/$projectId/completion_snapshots/$completionSnapshotId/edit"
)({
  component: RouteComponent,
  loader: ({
    context: { queryClient },
    params: { completionSnapshotId, projectId, companyId },
  }) =>
    queryClient
      .ensureQueryData(
        Api.queryOptions(
          "get",
          "/api/v1/organization/completion_snapshots/{id}",
          { params: { path: { id: Number(completionSnapshotId) } } }
        )
      )
      .then(async (completionSnapshotData) => {
        const previousCompletionSnapshotData =
          await queryClient.ensureQueryData(
            Api.queryOptions(
              "get",
              "/api/v1/organization/completion_snapshots/{id}/previous",
              { params: { path: { id: Number(completionSnapshotId) } } }
            )
          );

        return { completionSnapshotData, previousCompletionSnapshotData };
      })
      .then(async (completionSnapshotsData) => {
        const projectData = await queryClient.ensureQueryData(
          Api.queryOptions(
            "get",
            "/api/v1/organization/companies/{company_id}/projects/{id}",
            {
              params: {
                path: { company_id: Number(companyId), id: Number(projectId) },
              },
            }
          )
        );

        return { ...completionSnapshotsData, projectData };
      }),
});

function RouteComponent() {
  const loaderData = Route.useLoaderData();
  const { companyId, projectId, completionSnapshotId } = Route.useParams();
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
            loaderData.previousCompletionSnapshotData?.result
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
                loaderData.previousCompletionSnapshotData?.result
              }
              initialValues={loaderData.completionSnapshotData.result}
              completionSnapshotId={Number(completionSnapshotId)}
            />
          </CardContent>
        </Card>
      </Layout.Content>
    </Layout.Root>
  );
}
