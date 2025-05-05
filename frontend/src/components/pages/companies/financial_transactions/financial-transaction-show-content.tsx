import { Card, CardContent } from "@/components/ui/card";
import { FinancialTransactionExtended } from "./shared/types";
import { ReactNode } from "@tanstack/react-router";

import { TransactionDetails } from "./private/transaction-details";
import { TransactionOrderInvoicingSummaryCard } from "./private/transaction-order-invoicing-summary-card";

const FinancialTransactionShowContent = ({
  financialTransaction,
  children,
}: {
  children: ReactNode;
  financialTransaction: FinancialTransactionExtended;
}) => {
  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
      <div className="md:col-span-1 space-y-6">{children}</div>
      <div className="md:col-span-2">
        <Card>
          <CardContent className="mt-6 space-y-6">
            <TransactionOrderInvoicingSummaryCard
              financialTransaction={financialTransaction}
            />
            <TransactionDetails financialTransaction={financialTransaction} />
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

export { FinancialTransactionShowContent };
