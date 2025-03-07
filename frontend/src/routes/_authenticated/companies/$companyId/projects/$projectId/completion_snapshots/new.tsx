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
          "/api/v1/organization/projects/{id}/invoiced_items",
          { params: { path: { id: Number(projectId) } } }
        )
      )
      .then(async () =>
        queryClient.ensureQueryData(
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
      ),
});

function RouteComponent() {
  const { result: projectData } = Route.useLoaderData();
  const { companyId, projectId } = Route.useParams();
  const { t } = useTranslation();

  const { data: { results: invoicedItems } = { results: [] } } = Api.useQuery(
    "get",
    "/api/v1/organization/projects/{id}/invoiced_items",
    {
      params: { path: { id: Number(projectId) } },
    }
  );

  const previouslyInvoidedAmount = invoicedItems.reduce((prev, current) => {
    return prev + Number(current.invoiced_amount);
  }, 0);

  let previouslyInvoicedItems: Record<string, number> = {};
  previouslyInvoicedItems = invoicedItems.reduce((prev, current) => {
    prev[current.original_item_uuid] = Number(current.invoiced_amount);
    return prev;
  }, previouslyInvoicedItems);

  const projectVersionTotalAmount = projectData.last_version.items.reduce(
    (prev, current) => {
      return prev + (current.quantity * current.unit_price_cents) / 100;
    },
    0
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
          projectName={projectData.name}
          projectVersion={{
            number: projectData.last_version.number,
            created_at: projectData.last_version.created_at,
          }}
          previouslyInvoicedAmount={previouslyInvoidedAmount}
          projectTotalAmount={projectVersionTotalAmount}
        />
        <Card>
          <CardContent className="pt-6 space-y-6">
            <CompletionSnapshotFormNew
              companyId={Number(companyId)}
              projectId={Number(projectId)}
              itemGroups={projectData.last_version.item_groups}
              previouslyInvoicedItems={previouslyInvoicedItems}
              projectTotal={projectVersionTotalAmount}
            />
          </CardContent>
        </Card>
      </Layout.Content>
    </Layout.Root>
  );
}
