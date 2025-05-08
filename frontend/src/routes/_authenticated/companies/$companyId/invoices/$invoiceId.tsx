import { Api } from "@/lib/openapi-fetch-query-client";
import { createFileRoute } from "@tanstack/react-router";
import { Layout, LoadingLayout } from "@/components/pages/companies/layout";
import { useTranslation } from "react-i18next";
import { FinancialTransactionShowContent } from "@/components/pages/companies/financial_transactions/financial-transaction-show-content";
import { FinancialTransactionShowInvoiceSpecificContent } from "@/components/pages/companies/invoices/show/financial-transaction-show-invoice-specific-content";
import { PaymentStatusBadge } from "@/components/pages/companies/invoices/index/shared/payment-status-badge";
import { CancelledInvoiceBadge } from "@/components/pages/companies/invoices/shared/cancelled-status-badge";

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
          <h1 className="text-3xl font-bold">
            {t(
              `pages.companies.projects.invoices.completion_snapshot.show.title_published`,
              { number: invoice.number }
            )}
          </h1>
          {invoice.status === "cancelled" && <CancelledInvoiceBadge />}
          <PaymentStatusBadge
            status={invoice.payment_status}
            className="ml-auto"
          />
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
