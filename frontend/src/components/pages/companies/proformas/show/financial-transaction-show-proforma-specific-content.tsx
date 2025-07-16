import { ClientSummaryCard } from "@/components/pages/companies/clients/shared/client-summary-card";
import { ProformaExtended } from "../shared/types";
import { FinancialTransactionShowProformaSpecificContentActions } from "./financial-transaction-show-proforma-specific-content-actions";
import { Api } from "@/lib/openapi-fetch-query-client";
import { OrderSummaryCard } from "../../orders/shared/order-summary-card";

const FinancialTransactionShowProformaSpecificContent = ({
  companyId,
  proforma,
}: {
  companyId: string;
  proforma: ProformaExtended;
}) => {
  const { data: orderVersion } = Api.useQuery(
    "get",
    "/api/v1/organization/project_versions/{id}",
    { params: { path: { id: proforma.holder_id } } },
    { select: ({ result }) => result }
  );

  const { data: order } = Api.useQuery(
    "get",
    "/api/v1/organization/orders/{id}",
    { params: { path: { id: orderVersion?.project_id || -1 } } },
    { select: ({ result }) => result, enabled: orderVersion !== undefined }
  );

  const clientSummaryCardProps =
    order === undefined
      ? {
          email: proforma.detail.client_email,
          name: proforma.detail.client_name,
          phone: proforma.detail.client_phone,
        }
      : { clientId: order.client.id };

  return (
    <>
      {order == undefined ? (
        <OrderSummaryCard isLoading />
      ) : (
        <OrderSummaryCard companyId={companyId} orderId={order.id} />
      )}
      <ClientSummaryCard {...clientSummaryCardProps} />
      <FinancialTransactionShowProformaSpecificContentActions
        proforma={proforma}
        companyId={companyId}
      />
    </>
  );
};

export { FinancialTransactionShowProformaSpecificContent };
