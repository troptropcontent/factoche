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
import { NewInvoiceButton } from "../private/new-invoice-button";

const InvoicesSummary = ({
  companyId,
  orderId,
}: {
  companyId: number;
  orderId: number;
}) => {
  const { data: projectInvoices } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/invoices",
    {
      params: {
        path: { company_id: companyId },
        query: { status: ["cancelled", "draft", "posted"], order_id: orderId },
      },
    },
    {
      select: ({ results }) =>
        results.sort((a, b) => -b.issue_date.localeCompare(a.issue_date)),
    }
  );

  const navigate = useNavigate();

  const handleRowClick = (
    invoice: NonNullable<typeof projectInvoices>[number]
  ) => {
    navigate({
      to: "/companies/$companyId/invoices/$invoiceId",
      params: {
        companyId: companyId.toString(),
        invoiceId: invoice.id.toString(),
      },
    });
  };

  const { t } = useTranslation();

  if (projectInvoices == undefined) {
    return;
  }

  return (
    <Card className="mt-6">
      <CardHeader>
        <CardTitle>
          {t(
            "pages.companies.projects.show.completion_snapshot_invoices_summary.title"
          )}
        </CardTitle>
      </CardHeader>
      <CardContent>
        {projectInvoices.length > 0 && (
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
              {projectInvoices.map((invoice, index) => (
                <TableRow
                  key={index}
                  onClick={() => handleRowClick(invoice)}
                  className="cursor-pointer hover:bg-gray-100 transition-colors"
                  role="link"
                >
                  <TableCell>
                    {invoice.number ||
                      t(
                        "pages.companies.projects.show.completion_snapshot_invoices_summary.columns.number_when_empty"
                      )}
                  </TableCell>
                  <TableCell className="text-center">
                    {t("common.date", {
                      date: Date.parse(invoice.updated_at),
                    })}
                  </TableCell>
                  <TableCell className="text-center">
                    <StatusBadge status={invoice.status} />
                  </TableCell>
                  <TableCell className="text-right">
                    {t("common.number_in_currency", {
                      amount: invoice.total_amount,
                    })}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
        {projectInvoices.length === 0 && (
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
                to: "/companies/$companyId/orders/$orderId/invoices/new",
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
      {projectInvoices.length > 0 && (
        <CardFooter>
          <NewInvoiceButton {...{ companyId, orderId }} />
        </CardFooter>
      )}
    </Card>
  );
};

export { InvoicesSummary };
