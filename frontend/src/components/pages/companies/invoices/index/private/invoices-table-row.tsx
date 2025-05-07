import { TableCell, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { useNavigate } from "@tanstack/react-router";
import { DollarSign, FileText, MoreHorizontal } from "lucide-react";
import { InvoiceCompact } from "../../shared/types";
import { ProjectVersionCompact } from "../../../project-versions/shared/types";
import { OrderCompact } from "../../../projects/shared/types";
import { useTranslation } from "react-i18next";
import { findOrder } from "./utils";
import { PaymentStatusBadge } from "../shared/payment-status-badge";
import { Badge } from "@/components/ui/badge";
import {
  DropdownMenuContent,
  DropdownMenuItem,
} from "@/components/ui/dropdown-menu";
import { DropdownMenuTrigger } from "@/components/ui/dropdown-menu";
import { DropdownMenu } from "@/components/ui/dropdown-menu";
import { Api } from "@/lib/openapi-fetch-query-client";
import { toast } from "@/hooks/use-toast";
import { useQueryClient } from "@tanstack/react-query";

const CancelledBadge = () => {
  const { t } = useTranslation();
  return (
    <Badge variant="outline" className="ml-2 border-red-500 text-red-500">
      {t(
        "pages.companies.projects.invoices.index.tabs.invoices.status.cancelled"
      )}
    </Badge>
  );
};

const RowActions = ({
  invoice,
  companyId,
}: {
  invoice: InvoiceCompact;
  companyId: number;
}) => {
  const { t } = useTranslation();
  const { mutateAsync: createPaymentAsync } = Api.useMutation(
    "post",
    "/api/v1/organization/payments"
  );
  const queryClient = useQueryClient();
  const navigate = useNavigate();

  const createPaymentAndUpdateRelavantCachedData = async () => {
    await createPaymentAsync(
      { body: { invoice_id: invoice.id } },
      {
        onSuccess: (data) => {
          queryClient.setQueryData(
            Api.queryOptions(
              "get",
              "/api/v1/organization/companies/{company_id}/invoices",
              {
                params: { path: { company_id: companyId } },
              }
            ).queryKey,
            (oldData: { results: InvoiceCompact[] }) => {
              const updatedData = {
                ...oldData,
                results: oldData.results.map((oldDataInvoice) => {
                  if (oldDataInvoice.id === data.result.invoice_id) {
                    return { ...oldDataInvoice, payment_status: "paid" };
                  } else {
                    return oldDataInvoice;
                  }
                }),
              };

              return updatedData;
            }
          );
          toast({
            title: t(
              "pages.companies.completion_snapshot.show.actions.record_payment_success_toast_title"
            ),
            variant: "success",
          });
        },
        onError: () => {
          toast({
            variant: "destructive",
            title: t(
              "pages.companies.completion_snapshot.show.actions.record_payment_error_toast_title"
            ),
            description: t(
              "pages.companies.completion_snapshot.show.actions.record_payment_error_toast_description"
            ),
          });
        },
      }
    );
  };

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" size="icon">
          <MoreHorizontal className="h-4 w-4" />
          <span className="sr-only">
            {t(
              "pages.companies.projects.invoices.index.tabs.invoices.actions.open_actions_menu"
            )}
          </span>
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end">
        <DropdownMenuItem
          onClick={createPaymentAndUpdateRelavantCachedData}
          disabled={invoice.payment_status === "paid"}
        >
          <DollarSign className="mr-2 h-4 w-4" />
          {t(
            "pages.companies.projects.invoices.index.tabs.invoices.actions.record_payment"
          )}
        </DropdownMenuItem>
        <DropdownMenuItem
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
          <FileText className="mr-2 h-4 w-4" />
          {t(
            "pages.companies.projects.invoices.index.tabs.invoices.actions.view_details"
          )}
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
};

const InvoicesTableRow = ({
  companyId,
  document,
  orderVersions,
  orders,
}: {
  companyId: string;
  document: InvoiceCompact;
  orderVersions: ProjectVersionCompact[];
  orders: OrderCompact[];
}) => {
  const { t } = useTranslation();

  const order = findOrder(document, orderVersions, orders);
  if (order === undefined) {
    throw "order could not be found in the metada, this is likely a bug";
  }
  return (
    <TableRow key={document.id}>
      <TableCell className="font-medium">
        {document.number}
        {document.status === "cancelled" && <CancelledBadge />}
      </TableCell>
      <TableCell>{order.client.name}</TableCell>
      <TableCell>{order.name}</TableCell>
      <TableCell>
        {t("common.date", {
          date: Date.parse(document.issue_date),
        })}
      </TableCell>
      <TableCell>
        {t("common.number_in_currency", {
          amount: document.total_amount,
        })}
      </TableCell>
      <TableCell>
        <PaymentStatusBadge status={document.payment_status} />
      </TableCell>
      <TableCell className="text-right">
        <RowActions invoice={document} companyId={Number(companyId)} />
      </TableCell>
    </TableRow>
  );
};

export { InvoicesTableRow };
