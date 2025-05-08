import { useState } from "react";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Button } from "@/components/ui/button";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { AlertCircle, FilePlus } from "lucide-react";
import { PaymentStatusBadge } from "../../invoices/index/shared/payment-status-badge";
import { Api } from "@/lib/openapi-fetch-query-client";
import { useTranslation } from "react-i18next";
import { ProformaStatusBadge } from "../../proformas/shared/proforma-status-badge";
import { Link, useNavigate } from "@tanstack/react-router";

export default function InvoicingSection({
  orderId,
  companyId,
}: {
  orderId: number;
  companyId: number;
}) {
  const { data: invoices = [] } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/invoices",
    {
      params: { path: { company_id: companyId }, query: { order_id: orderId } },
    },
    { select: ({ results }) => results }
  );

  const { data: proformas = [] } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/proformas",
    {
      params: { path: { company_id: companyId }, query: { order_id: orderId } },
    },
    { select: ({ results }) => results }
  );

  const { t } = useTranslation();

  const [activeTab, setActiveTab] = useState("invoices");

  const navigate = useNavigate();

  const hasDraftProforma = proformas.some((p) => p.status === "draft");

  return (
    <Card>
      <CardHeader className="flex flex-row justify-between gap-2">
        <div>
          <CardTitle>
            {t("pages.companies.orders.show.invoices_summary.title")}
          </CardTitle>
          <CardDescription>
            {t("pages.companies.orders.show.invoices_summary.description")}
          </CardDescription>
        </div>
        {!hasDraftProforma && (
          <div>
            <Button asChild>
              <Link
                to={`/companies/$companyId/orders/$orderId/proformas/new`}
                params={{
                  companyId: companyId.toString(),
                  orderId: orderId.toString(),
                }}
                title={t(
                  "pages.companies.orders.show.invoices_summary.new_proforma_button.title"
                )}
              >
                <FilePlus className="h-4 w-4" />
              </Link>
            </Button>
          </div>
        )}
      </CardHeader>
      <CardContent>
        {hasDraftProforma && (
          <div className="mb-8 p-3 bg-amber-50 border border-amber-200 rounded-md flex items-center">
            <AlertCircle className="h-5 w-5 text-amber-500 mr-2" />
            <div className="text-sm text-amber-800">
              {t("pages.companies.orders.show.invoices_summary.draft_hint")}
            </div>
          </div>
        )}

        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid w-full grid-cols-2 mb-6">
            <TabsTrigger value="invoices">
              {t(
                "pages.companies.orders.show.invoices_summary.tabs.invoices.title"
              )}
            </TabsTrigger>
            <TabsTrigger value="proformas">
              {t(
                "pages.companies.orders.show.invoices_summary.tabs.proformas.title"
              )}
            </TabsTrigger>
          </TabsList>

          <TabsContent value="invoices">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>
                    {t(
                      "pages.companies.orders.show.invoices_summary.tabs.invoices.columns.number"
                    )}
                  </TableHead>
                  <TableHead>
                    {t(
                      "pages.companies.orders.show.invoices_summary.tabs.invoices.columns.amount"
                    )}
                  </TableHead>
                  <TableHead>
                    {t(
                      "pages.companies.orders.show.invoices_summary.tabs.invoices.columns.date"
                    )}
                  </TableHead>
                  <TableHead>
                    {t(
                      "pages.companies.orders.show.invoices_summary.tabs.invoices.columns.status"
                    )}
                  </TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {invoices.map((invoice) => (
                  <TableRow
                    key={invoice.id}
                    onClick={() =>
                      navigate({
                        to: "/companies/$companyId/invoices/$invoiceId",
                        params: {
                          companyId: companyId.toString(),
                          invoiceId: invoice.id.toString(),
                        },
                      })
                    }
                  >
                    <TableCell>
                      <span className="font-medium">{invoice.number}</span>
                    </TableCell>
                    <TableCell>
                      {t("common.number_in_currency", {
                        amount: Number(invoice.total_excl_tax_amount),
                      })}
                    </TableCell>
                    <TableCell>
                      {t("common.date", {
                        date: Date.parse(invoice.issue_date),
                      })}
                    </TableCell>
                    <TableCell>
                      <PaymentStatusBadge status={invoice.payment_status} />
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TabsContent>

          <TabsContent value="proformas">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>
                    {t(
                      "pages.companies.orders.show.invoices_summary.tabs.proformas.columns.number"
                    )}
                  </TableHead>
                  <TableHead>
                    {t(
                      "pages.companies.orders.show.invoices_summary.tabs.proformas.columns.amount"
                    )}
                  </TableHead>
                  <TableHead>
                    {t(
                      "pages.companies.orders.show.invoices_summary.tabs.proformas.columns.date"
                    )}
                  </TableHead>
                  <TableHead>
                    {t(
                      "pages.companies.orders.show.invoices_summary.tabs.proformas.columns.status"
                    )}
                  </TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {proformas.map((proforma) => (
                  <TableRow
                    key={proforma.id}
                    className={proforma.status === "draft" ? "bg-amber-50" : ""}
                    onClick={() =>
                      navigate({
                        to: "/companies/$companyId/proformas/$proformaId",
                        params: {
                          companyId: companyId.toString(),
                          proformaId: proforma.id.toString(),
                        },
                      })
                    }
                  >
                    <TableCell>
                      <span className="font-medium">{proforma.number}</span>
                    </TableCell>
                    <TableCell>
                      {t("common.number_in_currency", {
                        amount: Number(proforma.total_excl_tax_amount),
                      })}
                    </TableCell>
                    <TableCell>
                      {t("common.date", {
                        date: Date.parse(proforma.issue_date),
                      })}
                    </TableCell>
                    <TableCell>
                      <ProformaStatusBadge status={proforma.status} />
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TabsContent>
        </Tabs>
      </CardContent>
    </Card>
  );
}
