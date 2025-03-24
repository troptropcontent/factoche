import { InvoicesSummary } from "../invoices-summary";

const OrderSpecificSection = ({
  orderId,
  companyId,
}: {
  orderId: number;
  companyId: number;
}) => <InvoicesSummary companyId={companyId} orderId={orderId} />;

export { OrderSpecificSection };
