import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { TableBody, TableCell } from "@/components/ui/table";
import { TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Table } from "@/components/ui/table";
import { Api } from "@/lib/openapi-fetch-query-client";
import { useWatch } from "react-hook-form";
import { useTranslation } from "react-i18next";
import { invoiceFormSchema } from "./schemas";
import { z } from "zod";

const FormProjectSummary = ({ orderId }: { orderId: number }) => {
  const { t } = useTranslation();
  const { data: projectData } = Api.useQuery(
    "get",
    "/api/v1/organization/orders/{id}",
    {
      params: {
        path: { id: orderId },
      },
    }
  );
  const { data: invoicedItemsData } = Api.useQuery(
    "get",
    "/api/v1/organization/projects/{id}/invoiced_items",
    {
      params: { path: { id: Number(orderId) } },
    }
  );

  const formValues = useWatch<z.infer<typeof invoiceFormSchema>>();

  if (invoicedItemsData == undefined || projectData == undefined) {
    return null;
  }

  const {
    result: {
      name,
      last_version: { number, created_at, items },
    },
  } = projectData;

  const projectVersionTotalAmount = items.reduce((prev, current) => {
    return prev + current.quantity * Number(current.unit_price_amount);
  }, 0);

  const projectPreviouslyInvoicedAmount = invoicedItemsData.results.reduce(
    (prev, current) => {
      return prev + Number(current.invoiced_amount);
    },
    0
  );

  const newInvoiceAmount =
    formValues.invoice_amounts?.reduce((prev, { invoice_amount }) => {
      return prev + Number(invoice_amount || 0);
    }, 0) || 0;

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
              <TableCell className="max-w-[200px] text-wrap" title={name}>
                {name}
              </TableCell>
              <TableCell className="text-center">
                {t("pages.companies.projects.show.version_label", {
                  number: number,
                  createdAt: Date.parse(created_at),
                })}
              </TableCell>
              <TableCell className="text-center">
                {t("common.number_in_currency", {
                  amount: projectVersionTotalAmount,
                })}
              </TableCell>
              <TableCell className="text-center">
                {t("common.number_in_currency", {
                  amount: projectPreviouslyInvoicedAmount,
                })}
              </TableCell>
              <TableCell className="text-center">
                {t("common.number_in_currency", {
                  amount: newInvoiceAmount,
                })}
              </TableCell>
              <TableCell className="text-right">
                {t("common.number_in_currency", {
                  amount:
                    projectVersionTotalAmount -
                    projectPreviouslyInvoicedAmount -
                    newInvoiceAmount,
                })}
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
};

export { FormProjectSummary };
