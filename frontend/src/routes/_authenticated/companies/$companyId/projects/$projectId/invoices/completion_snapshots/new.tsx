import { CompletionSnapshotInvoiceForm } from "@/components/pages/companies/invoices/completion_snapshots/completion-snapshot-invoice-form";
import { Layout } from "@/components/pages/companies/layout";

import { Api } from "@/lib/openapi-fetch-query-client";
import { createFileRoute } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/projects/$projectId/invoices/completion_snapshots/new"
)({
  component: RouteComponent,
  loader: ({ context: { queryClient }, params: { companyId, projectId } }) =>
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

  let previouslyInvoicedAmountsPerItems: Record<string, number> = {};
  previouslyInvoicedAmountsPerItems = invoicedItems.reduce((prev, current) => {
    prev[current.original_item_uuid] = Number(current.invoiced_amount);
    return prev;
  }, previouslyInvoicedAmountsPerItems);

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
            {t(
              "pages.companies.projects.invoices.completion_snapshot.new.title"
            )}
          </h1>
        </div>
      </Layout.Header>
      <Layout.Content>
        <CompletionSnapshotInvoiceForm
          companyId={Number(companyId)}
          projectId={Number(projectId)}
          projectVersionId={projectData.last_version.id}
          itemGroups={projectData.last_version.item_groups}
          items={projectData.last_version.items}
          projectTotal={projectVersionTotalAmount}
          previouslyInvoicedAmountsPerItems={previouslyInvoicedAmountsPerItems}
        />
      </Layout.Content>
    </Layout.Root>
  );
}
