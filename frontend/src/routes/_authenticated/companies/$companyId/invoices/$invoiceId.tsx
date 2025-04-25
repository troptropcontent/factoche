import { Api } from "@/lib/openapi-fetch-query-client";
import { createFileRoute } from "@tanstack/react-router";
import { StatusBadge } from "@/components/pages/companies/invoices/private/status-badge";
import { Layout, LoadingLayout } from "@/components/pages/companies/layout";
import { useTranslation } from "react-i18next";
import { FinancialTransactionShowContent } from "@/components/pages/companies/financial_transactions/financial-transaction-show-content";
import { FinancialTransactionShowInvoiceSpecificContent } from "@/components/pages/companies/invoices/show/financial-transaction-show-invoice-specific-content";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/invoices/$invoiceId"
)({
  component: RouteComponent,
});

function RouteComponent() {
  const { invoiceId, companyId } = Route.useParams();
  const { data: invoice } = Api.useQuery(
    "get",
    "/api/v1/organization/invoices/{id}",
    { params: { path: { id: Number(invoiceId) } } },
    { select: ({ result }) => result }
  );
  const { t } = useTranslation();

  return invoice == undefined ? (
    <LoadingLayout />
  ) : (
    <Layout.Root>
      <Layout.Header>
        <div className="flex flex-grow items-center">
          <h1 className="text-3xl font-bold mr-auto">
            {t(
              `pages.companies.projects.invoices.completion_snapshot.show.title_published`,
              { number: invoice.number }
            )}
          </h1>
          <StatusBadge status={invoice.status} />
        </div>
      </Layout.Header>
      <Layout.Content>
        <FinancialTransactionShowContent financialTransaction={invoice}>
          <FinancialTransactionShowInvoiceSpecificContent
            invoice={invoice}
            companyId={companyId}
          />
        </FinancialTransactionShowContent>
      </Layout.Content>
    </Layout.Root>
  );
}
