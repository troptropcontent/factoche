import { createFileRoute } from "@tanstack/react-router";
import { Layout } from "@/components/pages/companies/layout";

import { Api } from "@/lib/openapi-fetch-query-client";
import { useTranslation } from "react-i18next";
import { InvoiceForm } from "@/components/pages/companies/invoices/invoice-form";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/orders/$orderId/invoices/new"
)({
  component: RouteComponent,
  loader: ({ context: { queryClient }, params: { orderId } }) =>
    queryClient.ensureQueryData(
      Api.queryOptions("get", "/api/v1/organization/orders/{id}", {
        params: {
          path: { id: Number(orderId) },
        },
      })
    ),
});

function RouteComponent() {
  const { result: projectData } = Route.useLoaderData();
  const { companyId, orderId } = Route.useParams();
  const { t } = useTranslation();

  const { data: { results: invoicedItems } = { results: [] } } = Api.useQuery(
    "get",
    "/api/v1/organization/orders/{id}/invoiced_items",
    {
      params: { path: { id: Number(orderId) } },
    }
  );

  let previouslyInvoicedAmountsPerItems: Record<string, number> = {};
  previouslyInvoicedAmountsPerItems = invoicedItems.reduce((prev, current) => {
    prev[current.original_item_uuid] = Number(current.invoiced_amount);
    return prev;
  }, previouslyInvoicedAmountsPerItems);

  const projectVersionTotalAmount = projectData.last_version.items.reduce(
    (prev, current) => {
      return prev + current.quantity * Number(current.unit_price_amount);
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
        <InvoiceForm
          companyId={Number(companyId)}
          orderId={Number(orderId)}
          itemGroups={projectData.last_version.item_groups}
          items={projectData.last_version.items.map((item) => ({
            ...item,
            unit_price_amount: Number(item.unit_price_amount),
          }))}
          projectTotal={projectVersionTotalAmount}
          previouslyInvoicedAmountsPerItems={previouslyInvoicedAmountsPerItems}
        />
      </Layout.Content>
    </Layout.Root>
  );
}
