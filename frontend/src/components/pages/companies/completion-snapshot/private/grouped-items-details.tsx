import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Item, ItemGroup } from "../../project-versions/shared/types";
import { CompletionSnapshotItem } from "../shared/types";
import {
  Table,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { computeItemTotalCents } from "../../project-versions/shared/utils";
import { useTranslation } from "react-i18next";
import { computeItemCompletionSnapshotValueCents } from "../shared/utils";

const ItemRow = ({
  groupedItem,
  completionSnapshotItems,
}: {
  groupedItem: Item;
  completionSnapshotItems: Array<CompletionSnapshotItem>;
}) => {
  const { t } = useTranslation();
  const itemTotalCents = computeItemTotalCents(groupedItem);
  // TODO: Previous completion snapshots will be developped soon, the logic needs to be sharpened and the backend modified
  const previouslyInvoicedCents = 0;
  const thisItemCompletionSnapshotValueCents =
    computeItemCompletionSnapshotValueCents(
      groupedItem,
      completionSnapshotItems
    );
  const thisItemInvoiceAmount =
    thisItemCompletionSnapshotValueCents - previouslyInvoicedCents;

  return (
    <TableRow>
      <TableCell>{groupedItem.name}</TableCell>
      <TableCell>
        {t("common.number_in_currency", {
          amount: itemTotalCents / 100,
        })}
      </TableCell>
      <TableCell>
        {t("common.number_in_currency", {
          amount: previouslyInvoicedCents / 100,
        })}
      </TableCell>
      <TableCell>
        {t("common.number_in_percentage", {
          amount: previouslyInvoicedCents / itemTotalCents / 100,
        })}
      </TableCell>
      <TableCell>
        {t("common.number_in_currency", {
          amount: thisItemCompletionSnapshotValueCents / 100,
        })}
      </TableCell>
      <TableCell>
        {t("common.number_in_percentage", {
          amount: (thisItemCompletionSnapshotValueCents / itemTotalCents) * 100,
        })}
      </TableCell>
      <TableCell>
        {t("common.number_in_currency", {
          amount: thisItemInvoiceAmount / 100,
        })}
      </TableCell>
    </TableRow>
  );
};

const GroupedItemsDetails = ({
  itemGroups,
  completionSnapshotItems,
}: {
  itemGroups: Array<ItemGroup>;
  completionSnapshotItems: Array<CompletionSnapshotItem>;
}) => {
  const { t } = useTranslation();
  return (
    <div className="space-y-6">
      {itemGroups.map((itemGroup) => (
        <Card>
          <CardHeader>
            <CardTitle>{itemGroup.name}</CardTitle>
            {itemGroup.description && (
              <CardDescription>{itemGroup.description}</CardDescription>
            )}
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>
                    {t(
                      "pages.companies.completion_snapshot.grouped_items_details.designation"
                    )}
                  </TableHead>
                  <TableHead>
                    {t(
                      "pages.companies.completion_snapshot.grouped_items_details.total_amount"
                    )}
                  </TableHead>
                  <TableHead colSpan={2}>
                    {t(
                      "pages.companies.completion_snapshot.grouped_items_details.previous_invoiced_label"
                    )}
                  </TableHead>
                  <TableHead colSpan={2}>
                    {t(
                      "pages.companies.completion_snapshot.grouped_items_details.new_completion_snapshot_label"
                    )}
                  </TableHead>
                  <TableHead>
                    {t(
                      "pages.companies.completion_snapshot.grouped_items_details.new_invoiced_label"
                    )}
                  </TableHead>
                </TableRow>
              </TableHeader>
              {itemGroup.grouped_items.map((grouped_item) => (
                <ItemRow
                  groupedItem={grouped_item}
                  completionSnapshotItems={completionSnapshotItems}
                />
              ))}
            </Table>
          </CardContent>
        </Card>
      ))}
    </div>
  );
};

export { GroupedItemsDetails };
