import { CompletionSnapshotFormNew } from "@/components/pages/companies/completion-snapshot/completion-snapshot-form-new";
import { ProjectSummary } from "@/components/pages/companies/completion-snapshot/project-summary";
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
  const mappedInitialValues: typeof loaderData.completionSnapshotData.result = {
    ...loaderData.completionSnapshotData.result,
    completion_snapshot_items:
      loaderData.completionSnapshotData.result.completion_snapshot_items.map(
        (completion_snapshot_item) => ({
          ...completion_snapshot_item,
          completion_percentage: (
            Number(completion_snapshot_item.completion_percentage) * 100
          ).toString(),
        })
      ),
  };

  const previouslyInvoicedItems: Record<string, number> =
    loaderData.completionSnapshotData.result.invoice.payload.transaction.items.reduce(
      (prev, current) => {
        prev[current.original_item_uuid] = parseFloat(
          current.previously_invoiced_amount
        );
        return prev;
      },
      {}
    );

  console.log({ previouslyInvoicedItems });

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
              loaderData.completionSnapshotData.result.invoice.payload
                .project_context.version.number,
            created_at:
              loaderData.completionSnapshotData.result.invoice.payload
                .project_context.version.date,
          }}
          previouslyInvoicedAmount={parseFloat(
            loaderData.completionSnapshotData.result.invoice.payload
              .project_context.previously_billed_amount
          )}
          projectTotalAmount={parseFloat(
            loaderData.completionSnapshotData.result.invoice.payload
              .project_context.total_amount
          )}
        />
        <Card>
          <CardContent className="pt-6 space-y-6">
            <CompletionSnapshotFormNew
              projectTotal={parseFloat(
                loaderData.completionSnapshotData.result.invoice.payload
                  .project_context.total_amount
              )}
              companyId={Number(companyId)}
              projectId={Number(projectId)}
              itemGroups={
                loaderData.projectData.result.last_version.item_groups
              }
              previouslyInvoicedItems={previouslyInvoicedItems}
              initialValues={mappedInitialValues}
              completionSnapshotId={Number(completionSnapshotId)}
            />
          </CardContent>
        </Card>
      </Layout.Content>
    </Layout.Root>
  );
}
