import { InvoiceShowContent } from "@/components/pages/companies/invoices/invoice-show-content";
import { StatusBadge } from "@/components/pages/companies/invoices/private/status-badge";
import { Layout } from "@/components/pages/companies/layout";
import { Api } from "@/lib/openapi-fetch-query-client";
import { createFileRoute } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/orders/$orderId/invoices/$invoiceId/"
)({
  component: RouteComponent,
  loader: ({ context: { queryClient }, params: { invoiceId, companyId } }) =>
    queryClient.ensureQueryData(
      Api.queryOptions(
        "get",
        "/api/v1/organization/companies/{company_id}/invoices/{id}",
        {
          params: {
            path: { id: Number(invoiceId), company_id: Number(companyId) },
          },
        }
      )
    ),
});

function RouteComponent() {
  const { result: invoice } = Route.useLoaderData();
  const { companyId, invoiceId, orderId } = Route.useParams();
  const { t } = useTranslation();

  return (
    <Layout.Root>
      <Layout.Header>
        <div className="flex flex-grow items-center">
          <h1 className="text-3xl font-bold mr-auto">
            {t(
              `pages.companies.projects.invoices.completion_snapshot.show.title_${invoice.status == "draft" || invoice.status == "voided" ? "unpublished" : "published"}`,
              { number: invoice.number }
            )}
          </h1>
          <StatusBadge status={invoice.status} />
        </div>
      </Layout.Header>
      <Layout.Content>
        <InvoiceShowContent
          routeParams={{
            companyId: Number(companyId),
            invoiceId: Number(invoiceId),
            orderId: Number(orderId),
          }}
        />
      </Layout.Content>
    </Layout.Root>
  );
}
