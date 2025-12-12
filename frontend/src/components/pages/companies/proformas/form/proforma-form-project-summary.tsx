import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { TableBody, TableCell } from "@/components/ui/table";
import { TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Table } from "@/components/ui/table";
import { Api } from "@/lib/openapi-fetch-query-client";
import { useWatch } from "react-hook-form";
import { useTranslation } from "react-i18next";

import { z } from "zod";
import { proformaFormSchema } from "./proforma-form-schema";
import {
  computePreviouslyInvoicedAmount,
  computeProformaAmounts,
} from "./utils";

const ProformaFormProjectSummary = ({ orderId }: { orderId: number }) => {
  const { t } = useTranslation();
  const { data: order } = Api.useQuery(
    "get",
    "/api/v1/organization/orders/{id}",
    {
      params: {
        path: { id: orderId },
      },
    },
    { select: ({ result }) => result }
  );
  const { data: invoicedItems } = Api.useQuery(
    "get",
    "/api/v1/organization/orders/{id}/invoiced_items",
    {
      params: { path: { id: Number(orderId) } },
    },
    { select: ({ results }) => results }
  );

  const formValues = useWatch<z.infer<typeof proformaFormSchema>>();

  if (invoicedItems == undefined || order == undefined) {
    return null;
  }

  const projectPreviouslyInvoicedAmount =
    computePreviouslyInvoicedAmount(invoicedItems);

  const { invoiceAmount } = computeProformaAmounts(formValues, order);

  return (
    <Card>
      <CardHeader>
        <CardTitle>
          {t(
            "pages.companies.projects.invoices.completion_snapshot.form.project_summary.title"
          )}{" "}
        </CardTitle>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="w-[25%]">
                {t(
                  "pages.companies.projects.invoices.completion_snapshot.form.project_summary.columns.name"
                )}
              </TableHead>
              <TableHead className="w-[15%] text-center">
                {t(
                  "pages.companies.projects.invoices.completion_snapshot.form.project_summary.columns.version"
                )}
              </TableHead>
              <TableHead className="w-[15%] text-center">
                {t(
                  "pages.companies.projects.invoices.completion_snapshot.form.project_summary.columns.total"
                )}
              </TableHead>
              <TableHead className="w-[15%] text-center">
                {t(
                  "pages.companies.projects.invoices.completion_snapshot.form.project_summary.columns.previously_invoiced"
                )}
              </TableHead>
              <TableHead className="w-[15%] text-center">
                {t(
                  "pages.companies.projects.invoices.completion_snapshot.form.project_summary.columns.new_invoice_amount"
                )}
              </TableHead>
              <TableHead className="w-[15%] text-right">
                {t(
                  "pages.companies.projects.invoices.completion_snapshot.form.project_summary.columns.remaining_amount"
                )}
              </TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow>
              <TableCell className="max-w-[200px] text-wrap" title={order.name}>
                {order.name}
              </TableCell>
              <TableCell className="text-center">
                {t("pages.companies.projects.show.version_label", {
                  number: order.last_version.number,
                  createdAt: Date.parse(order.last_version.created_at),
                })}
              </TableCell>
              <TableCell className="text-center">
                {t("common.number_in_currency", {
                  amount: order.last_version.total_excl_tax_amount,
                })}
              </TableCell>
              <TableCell className="text-center">
                {t("common.number_in_currency", {
                  amount: projectPreviouslyInvoicedAmount,
                })}
              </TableCell>
              <TableCell className="text-center">
                {t("common.number_in_currency", {
                  amount: invoiceAmount,
                })}
              </TableCell>
              <TableCell className="text-right">
                {t("common.number_in_currency", {
                  amount:
                    Number(order.last_version.total_excl_tax_amount) -
                    projectPreviouslyInvoicedAmount -
                    invoiceAmount,
                })}
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
};

export { ProformaFormProjectSummary };
