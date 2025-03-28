import { Api } from "@/lib/openapi-fetch-query-client";
import { computeInvoiceTotal } from "@/components/pages/companies/invoices/shared/utils";

const useInvoiceTotalAmount = ({
  invoiceId,
  companyId,
}: {
  companyId: number;
  invoiceId: number;
}) => {
  const { data: invoiceData } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/invoices/{id}",
    {
      params: {
        path: { company_id: companyId, id: invoiceId },
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
