import {
  Card,
  CardContent,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { useTranslation } from "react-i18next";

import { useNavigate } from "@tanstack/react-router";
import { TrafficCone } from "lucide-react";
import { EmptyState } from "@/components/ui/empty-state";

import { Api } from "@/lib/openapi-fetch-query-client";
import { StatusBadge } from "../../invoices/private/status-badge";
import { NewProformaButton } from "./new-proforma-button";

const InvoicesSummary = ({
  companyId,
  orderId,
}: {
  companyId: number;
  orderId: number;
}) => {
  const { data: orderInvoices } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/invoices",
    {
      params: {
        path: { company_id: companyId },
        query: { order_id: orderId },
      },
    },
    {
      select: ({ results }) =>
        results.map((invoice) => ({ ...invoice, type: "invoice" as const })),
    }
  );

  const { data: orderProformas } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/proformas",
    {
      params: {
        path: { company_id: companyId },
        query: { order_id: orderId },
      },
    },
    {
      select: ({ results }) =>
        results
          .map((proforma) => ({ ...proforma, type: "proforma" as const }))
          .filter((proforma) => proforma.status == "draft"),
    }
  );

  const ordersFinancialTransactions =
    orderInvoices !== undefined && orderProformas !== undefined
      ? [...orderInvoices, ...orderProformas].sort((a, b) => {
          return Date.parse(a.issue_date) - Date.parse(b.issue_date);
        })
      : undefined;

  const navigate = useNavigate();

  const handleRowClick = (
    financialTransaction: NonNullable<
      typeof ordersFinancialTransactions
    >[number]
  ) => {
    const path =
      financialTransaction.type === "invoice"
        ? `/companies/$companyId/invoices/$invoiceId`
        : `/companies/$companyId/proformas/$proformaId`;

    navigate({
      to: path,
      params: {
        companyId: companyId.toString(),
        invoiceId: financialTransaction.id.toString(),
        proformaId: financialTransaction.id.toString(),
      },
    });
  };

  const { t } = useTranslation();

  if (ordersFinancialTransactions == undefined) {
    return;
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>
          {t(
            "pages.companies.projects.show.completion_snapshot_invoices_summary.title"
          )}
        </CardTitle>
      </CardHeader>
      <CardContent>
        {ordersFinancialTransactions.length > 0 && (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>
                  {t(
                    "pages.companies.projects.show.completion_snapshot_invoices_summary.columns.number"
                  )}
                </TableHead>
                <TableHead className="text-center">
                  {t(
                    "pages.companies.projects.show.completion_snapshot_invoices_summary.columns.date"
                  )}
                </TableHead>
                <TableHead className="text-center">
                  {t(
                    "pages.companies.projects.show.completion_snapshot_invoices_summary.columns.status"
                  )}
                </TableHead>
                <TableHead className="text-right">
                  {t(
                    "pages.companies.projects.show.completion_snapshot_invoices_summary.columns.amount"
                  )}
                </TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {ordersFinancialTransactions.map(
                (financialTransaction, index) => (
                  <TableRow
                    key={index}
                    onClick={() => handleRowClick(financialTransaction)}
                    className="cursor-pointer hover:bg-gray-100 transition-colors"
                    role="link"
                  >
                    <TableCell>
                      {financialTransaction.number ||
                        t(
                          "pages.companies.projects.show.completion_snapshot_invoices_summary.columns.number_when_empty"
                        )}
                    </TableCell>
                    <TableCell className="text-center">
                      {t("common.date", {
                        date: Date.parse(financialTransaction.updated_at),
                      })}
                    </TableCell>
                    <TableCell className="text-center">
                      <StatusBadge status={financialTransaction.status} />
                    </TableCell>
                    <TableCell className="text-right">
                      {t("common.number_in_currency", {
                        amount: financialTransaction.total_amount,
                      })}
                    </TableCell>
                  </TableRow>
                )
              )}
            </TableBody>
          </Table>
        )}
        {ordersFinancialTransactions.length === 0 && (
          <EmptyState
            icon={TrafficCone}
            title={t(
              "pages.companies.projects.show.completion_snapshot_invoices_summary.empty_state.title"
            )}
            description={t(
              "pages.companies.projects.show.completion_snapshot_invoices_summary.empty_state.description"
            )}
            action={t(
              "pages.companies.projects.show.completion_snapshot_invoices_summary.empty_state.action_label"
            )}
            onAction={() => {
              navigate({
                to: "/companies/$companyId/orders/$orderId/proformas/new",
                params: {
                  companyId: companyId.toString(),
                  orderId: orderId.toString(),
                },
              });
            }}
            className="flex-grow mb-4"
          />
        )}
      </CardContent>
      {ordersFinancialTransactions.length > 0 && (
        <CardFooter>
          <NewProformaButton {...{ companyId, orderId }} />
        </CardFooter>
      )}
    </Card>
  );
};

export { InvoicesSummary };
