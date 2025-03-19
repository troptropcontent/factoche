import { Api } from "@/lib/openapi-fetch-query-client";
import { computeInvoiceTotal } from "@/components/pages/companies/invoices/shared/utils";

const useInvoiceTotalAmount = ({
  orderId,
  invoiceId,
}: {
  orderId: number;
  invoiceId: number;
}) => {
  const { data: invoiceData } = Api.useQuery(
    "get",
    "/api/v1/organization/orders/{order_id}/invoices/{id}",
    {
      params: {
        path: { order_id: orderId, id: invoiceId },
      },
    },
    { select: ({ result }) => result }
  );

  if (invoiceData == undefined) {
    return {
      invoiceTotalAmount: undefined,
    };
  }

  return {
    invoiceTotalAmount: computeInvoiceTotal(invoiceData.lines),
  };
};

export { useInvoiceTotalAmount };
