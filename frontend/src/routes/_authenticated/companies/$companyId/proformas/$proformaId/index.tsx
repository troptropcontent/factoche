import { FinancialTransactionShowContent } from "@/components/pages/companies/financial_transactions/financial-transaction-show-content";
import { StatusBadge } from "@/components/pages/companies/invoices/private/status-badge";
import { Layout, LoadingLayout } from "@/components/pages/companies/layout";
import { FinancialTransactionShowProformaSpecificContent } from "@/components/pages/companies/proformas/show/financial-transaction-show-proforma-specific-content";
import { Api } from "@/lib/openapi-fetch-query-client";
import { createFileRoute } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/proformas/$proformaId/"
)({
  component: RouteComponent,
});

function RouteComponent() {
  const { proformaId, companyId } = Route.useParams();
  const { data: proforma } = Api.useQuery(
    "get",
    "/api/v1/organization/proformas/{id}",
    { params: { path: { id: Number(proformaId) } } },
    { select: ({ result }) => result }
  );
  const { t } = useTranslation();

  return proforma == undefined ? (
    <LoadingLayout />
  ) : (
    <Layout.Root>
      <Layout.Header>
        <div className="flex flex-grow items-center">
          <h1 className="text-3xl font-bold mr-auto">
            {t(`pages.companies.proformas.show.title`, {
              number: proforma.number,
              issue_date: Date.parse(proforma.issue_date),
            })}
          </h1>
          <StatusBadge status={proforma.status} />
        </div>
      </Layout.Header>
      <Layout.Content>
        <FinancialTransactionShowContent financialTransaction={proforma}>
          <FinancialTransactionShowProformaSpecificContent
            proforma={proforma}
            companyId={companyId}
          />
        </FinancialTransactionShowContent>
      </Layout.Content>
    </Layout.Root>
  );
}
