import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useTranslation } from "react-i18next";
import { FinancialTransactionExtended } from "../shared/types";
import { TransactionDetailsUngrouped } from "./transaction-details-ungrouped";
import { TransactionDetailsGrouped } from "./transaction-details-grouped";
import { TransactionDetailsDiscounts } from "./transaction-details-discounts";

const TransactionDetails = ({
  financialTransaction,
}: {
  financialTransaction: FinancialTransactionExtended;
}) => {
  const { t } = useTranslation();
  const areTransactionLinesGrouped =
    financialTransaction.context.project_version_item_groups.length > 0;

  return (
    <Card>
      <CardHeader>
        <CardTitle>
          {t("pages.companies.completion_snapshot.grouped_items_details.title")}
        </CardTitle>
      </CardHeader>
      <CardContent>
        {areTransactionLinesGrouped ? (
          <TransactionDetailsGrouped
            groups={financialTransaction.context.project_version_item_groups}
            items={financialTransaction.context.project_version_items}
            transactionLines={financialTransaction.lines}
          />
        ) : (
          <TransactionDetailsUngrouped />
        )}
        <TransactionDetailsDiscounts
          financialTransaction={financialTransaction}
        />
      </CardContent>
    </Card>
  );
};

export { TransactionDetails };
