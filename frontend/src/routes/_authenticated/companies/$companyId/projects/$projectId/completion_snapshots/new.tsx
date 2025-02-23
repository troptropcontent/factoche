import { CompletionSnapshotFormNew } from "@/components/pages/companies/completion-snapshot/completion-snapshot-form-new";
import { ProjectSummary } from "@/components/pages/companies/completion-snapshot/project-summary";
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
        const baseCompletionSnapshotData = await queryClient.ensureQueryData(
          Api.queryOptions(
            "get",
            "/api/v1/organization/project_versions/{project_version_id}/completion_snapshots/new_completion_snapshot_data",
            {
              params: {
                path: {
                  project_version_id: projectData.result.last_version.id,
                },
              },
            }
          )
        );

        return { projectData, baseCompletionSnapshotData };
      }),
});

function RouteComponent() {
  const loaderData = Route.useLoaderData();
  const { companyId, projectId } = Route.useParams();
  const { t } = useTranslation();
  const previouslyInvoicedItems: Record<string, number> =
    loaderData.baseCompletionSnapshotData.result.invoice.payload.transaction.items.reduce(
      (prev, current) => {
        prev[current.original_item_uuid] = parseFloat(
          current.previously_invoiced_amount
        );
        return prev;
      },
      {}
    );

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
        <ProjectSummary
          projectName={loaderData.projectData.result.name}
          projectVersion={{
            number:
              loaderData.baseCompletionSnapshotData.result.invoice.payload
                .project_context.version.number,
            created_at:
              loaderData.baseCompletionSnapshotData.result.invoice.payload
                .project_context.version.date,
          }}
          previouslyInvoicedAmount={parseFloat(
            loaderData.baseCompletionSnapshotData.result.invoice.payload
              .project_context.previously_billed_amount
          )}
          projectTotalAmount={parseFloat(
            loaderData.baseCompletionSnapshotData.result.invoice.payload
              .project_context.total_amount
          )}
        />
        <Card>
          <CardContent className="pt-6 space-y-6">
            <CompletionSnapshotFormNew
              companyId={Number(companyId)}
              projectId={Number(projectId)}
              itemGroups={
                loaderData.projectData.result.last_version.item_groups
              }
              previouslyInvoicedItems={previouslyInvoicedItems}
              projectTotal={parseFloat(
                loaderData.baseCompletionSnapshotData.result.invoice.payload
                  .project_context.total_amount
              )}
            />
          </CardContent>
        </Card>
      </Layout.Content>
    </Layout.Root>
  );
}
