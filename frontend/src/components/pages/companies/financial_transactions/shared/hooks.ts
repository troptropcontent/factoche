import { Api } from "@/lib/openapi-fetch-query-client";
import { InvoiceExtended } from "../../invoices/shared/types";
import { ProformaExtended } from "../../proformas/shared/types";

const useFindOrderIdFromFinancialTransaction = (
  fianncialTransaction: InvoiceExtended | ProformaExtended
) => {
  const { data: project_id } = Api.useQuery(
    "get",
    "/api/v1/organization/project_versions/{id}",
    { params: { path: { id: fianncialTransaction.holder_id } } },
    { select: ({ result: { project_id } }) => project_id }
  );

  return project_id;
};

export { useFindOrderIdFromFinancialTransaction };
