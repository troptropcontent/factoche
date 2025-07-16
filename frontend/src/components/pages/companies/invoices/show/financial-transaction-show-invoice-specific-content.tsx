import { ClientSummaryCard } from "@/components/pages/companies/clients/shared/client-summary-card";
import { InvoiceExtended } from "../shared/types";
import { FinancialTransactionShowInvoiceSpecificContentActions } from "./financial-transaction-show-invoice-specific-content-actions";

import { OrderSummaryCard } from "@/components/pages/companies/orders/shared/order-summary-card";
import { useFindOrderIdFromFinancialTransaction } from "@/components/pages/companies/financial_transactions/shared/hooks";

const FinancialTransactionShowInvoiceSpecificContent = ({
  companyId,
  invoice,
}: {
  companyId: string;
  invoice: InvoiceExtended;
}) => {
  const orderId = useFindOrderIdFromFinancialTransaction(invoice);

  return (
    <>
      {orderId == undefined ? (
        <OrderSummaryCard isLoading />
      ) : (
        <OrderSummaryCard
          companyId={companyId}
          orderId={orderId}
          name={invoice.context.project_name}
          version_date={invoice.context.project_version_date}
          version_number={invoice.context.project_version_number}
        />
      )}
      <ClientSummaryCard
        email={invoice.detail.client_email}
        name={invoice.detail.client_name}
        phone={invoice.detail.client_name}
      />
      <FinancialTransactionShowInvoiceSpecificContentActions
        invoice={invoice}
        companyId={companyId}
      />
    </>
  );
};

export { FinancialTransactionShowInvoiceSpecificContent };
