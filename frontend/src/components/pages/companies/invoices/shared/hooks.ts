import { Api } from "@/lib/openapi-fetch-query-client";
import { computeInvoiceTotal } from "@/components/pages/companies/invoices/shared/utils";

const useInvoiceTotalAmount = ({
  projectId,
  invoiceId,
}: {
  projectId: number;
  invoiceId: number;
}) => {
  const { data: invoiceData } = Api.useQuery(
    "get",
    "/api/v1/organization/projects/{project_id}/invoices/{id}",
    {
      params: {
        path: { project_id: projectId, id: invoiceId },
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
