import { FinancialTransactionExtended } from "../shared/types";
import { TransactionDetailsGroupedLines } from "./transaction-details-grouped-lines";

const TransactionDetailsGrouped = ({
  groups,
  items,
  transactionLines,
}: {
  groups: FinancialTransactionExtended["context"]["project_version_item_groups"];
  items: FinancialTransactionExtended["context"]["project_version_items"];
  transactionLines: FinancialTransactionExtended["lines"];
}) => {
  return (
    <>
      {groups.map((group) => (
        <TransactionDetailsGroupedLines
          key={group.id}
          group={group}
          items={items.filter((groupItem) => groupItem.group_id === group.id)}
          transactionLines={transactionLines}
        />
      ))}
    </>
  );
};

export { TransactionDetailsGrouped };
