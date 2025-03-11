import { CompletionSnapshotInvoiceForm } from "@/components/pages/companies/invoices/completion_snapshots/completion-snapshot-invoice-form";
import { Layout } from "@/components/pages/companies/layout";
import { Api } from "@/lib/openapi-fetch-query-client";
import { createFileRoute } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/projects/$projectId/invoices/$invoiceId/update"
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
  const { companyId, projectId, invoiceId } = Route.useParams();
  const { t } = useTranslation();

  const { data: { results: invoicedItems } = { results: [] } } = Api.useQuery(
    "get",
    "/api/v1/organization/projects/{id}/invoiced_items",
    {
      params: { path: { id: Number(projectId) } },
    }
  );

  const { data: invoiceAmounts } = Api.useQuery(
    "get",
    "/api/v1/organization/projects/{project_id}/invoices/{id}",
    {
      params: {
        path: { project_id: Number(projectId), id: Number(invoiceId) },
      },
    },
    { select: ({ result: { lines } }) => lines }
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

  const formInitialValues =
    invoiceAmounts === undefined
      ? { invoice_amounts: [] }
      : {
          invoice_amounts: projectData.last_version.items.map((item) => {
            const invoiceAmount = invoiceAmounts.find(
              (i) => i.holder_id == item.original_item_uuid
            )?.excl_tax_amount;
            return {
              original_item_uuid: item.original_item_uuid,
              invoice_amount: invoiceAmount ? Number(invoiceAmount) : 0,
            };
          }),
        };

  console.log({ formInitialValues });

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
        {invoiceAmounts === undefined ? (
          <div className="space-y-4">
            <div className="h-8 w-48 bg-gray-200 animate-pulse rounded" />
            <div className="space-y-2">
              {Array.from({ length: 3 }).map((_, i) => (
                <div
                  key={i}
                  className="h-12 bg-gray-200 animate-pulse rounded"
                />
              ))}
            </div>
          </div>
        ) : (
          <CompletionSnapshotInvoiceForm
            invoiceId={Number(invoiceId)}
            companyId={Number(companyId)}
            projectId={Number(projectId)}
            projectVersionId={projectData.last_version.id}
            itemGroups={projectData.last_version.item_groups}
            items={projectData.last_version.items}
            projectTotal={projectVersionTotalAmount}
            previouslyInvoicedAmountsPerItems={
              previouslyInvoicedAmountsPerItems
            }
            initialValues={formInitialValues}
          />
        )}
      </Layout.Content>
    </Layout.Root>
  );
}
