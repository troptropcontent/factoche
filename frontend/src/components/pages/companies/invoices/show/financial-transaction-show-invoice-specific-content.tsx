import { ClientSummaryCard } from "@/components/pages/companies/clients/shared/client-summary-card";
import { ProjectSummaryCard } from "@/components/pages/companies/projects/shared/project-summary-card";
import { InvoiceExtended } from "../shared/types";
import { FinancialTransactionShowInvoiceSpecificContentActions } from "./financial-transaction-show-invoice-specific-content-actions";

const FinancialTransactionShowInvoiceSpecificContent = ({
  companyId,
  invoice,
}: {
  companyId: string;
  invoice: InvoiceExtended;
}) => {
  return (
    <>
      <ProjectSummaryCard
        name={invoice.context.project_name}
        version_date={invoice.context.project_version_date}
        version_number={invoice.context.project_version_number}
      />
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
