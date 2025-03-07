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
  TableBody,
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
  previouslyBuiltAmount,
}: {
  previouslyBuiltAmount: number;
  groupedItem: Item;
  completionSnapshotItems: Array<CompletionSnapshotItem>;
}) => {
  const { t } = useTranslation();
  const itemTotalCents = computeItemTotalCents(groupedItem);

  // TODO: Previous completion snapshots will be developped soon, the logic needs to be sharpened and the backend modified

  const thisItemCompletionSnapshotValueCents =
    computeItemCompletionSnapshotValueCents(
      groupedItem,
      completionSnapshotItems
    );

  const thisItemInvoiceAmount =
    thisItemCompletionSnapshotValueCents / 100 - previouslyBuiltAmount;

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
          amount: previouslyBuiltAmount,
        })}
      </TableCell>
      <TableCell>
        {t("common.number_in_percentage", {
          amount: (previouslyBuiltAmount / (itemTotalCents / 100)) * 100,
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
          amount: thisItemInvoiceAmount,
        })}
      </TableCell>
    </TableRow>
  );
};

const GroupedItemsDetailsNew = ({
  itemGroups,
  completionSnapshotItems,
  invoice,
}: {
  itemGroups: Array<ItemGroup>;
  completionSnapshotItems: Array<CompletionSnapshotItem>;
  invoice: object;
}) => {
  const { t } = useTranslation();

  const findPreviouslyInvoiedAmount = (original_item_uuid: string) => {
    const payloadItem = invoice.payload.transaction.items.find(
      (item) => item.original_item_uuid === original_item_uuid
    );

    return payloadItem ? parseFloat(payloadItem.previously_invoiced_amount) : 0;
  };
  return (
    <div className="space-y-6">
      {itemGroups.map((itemGroup) => (
        <Card key={itemGroup.id}>
          <CardHeader>
            <CardTitle>{itemGroup.name}</CardTitle>
            {itemGroup.description && (
              <CardDescription>{itemGroup.description}</CardDescription>
            )}
          </CardHeader>
          <CardContent>
            <Table className="table-fixed">
              <TableHeader>
                <TableRow>
                  <TableHead className="w-[30%]">
                    {t(
                      "pages.companies.completion_snapshot.grouped_items_details.designation"
                    )}
                  </TableHead>
                  <TableHead className="w-[15%]">
                    {t(
                      "pages.companies.completion_snapshot.grouped_items_details.total_amount"
                    )}
                  </TableHead>
                  <TableHead colSpan={2} className="w-[20%]">
                    {t(
                      "pages.companies.completion_snapshot.grouped_items_details.previous_invoiced_label"
                    )}
                  </TableHead>
                  <TableHead colSpan={2} className="w-[20%]">
                    {t(
                      "pages.companies.completion_snapshot.grouped_items_details.new_completion_snapshot_label"
                    )}
                  </TableHead>
                  <TableHead className="w-[15%]">
                    {t(
                      "pages.companies.completion_snapshot.grouped_items_details.new_invoiced_label"
                    )}
                  </TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {itemGroup.grouped_items.map((grouped_item) => (
                  <ItemRow
                    key={grouped_item.id}
                    groupedItem={grouped_item}
                    completionSnapshotItems={completionSnapshotItems}
                    previouslyBuiltAmount={findPreviouslyInvoiedAmount(
                      grouped_item.original_item_uuid
                    )}
                  />
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      ))}
    </div>
  );
};

export { GroupedItemsDetailsNew };
