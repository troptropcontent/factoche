import { z } from "zod";
import { completionSnapshotFormSchema } from "./completion-snapshot-form.schemas";

type CompletionSnapshotItem = {
  item_id: number;
  completion_percentage: string;
};

type PreviousSnapshot = {
  completion_snapshot_items: CompletionSnapshotItem[];
};

type Item = {
  id: number;
  quantity: number;
  unit_price_cents: number;
};

type ItemGroup = {
  grouped_items: Item[];
};

const findPreviousCompletionPercentage = (
  itemId: number,
  previousSnapshot?: PreviousSnapshot
): number => {
  const previousPercentage = previousSnapshot?.completion_snapshot_items?.find(
    (item) => item.item_id === itemId
  )?.completion_percentage;

  return previousPercentage ? Number(previousPercentage) : 0;
};

const buildInitialValues = ({
  itemGroups,
  previousCompletionSnapshot,
}: {
  itemGroups: ItemGroup[];
  previousCompletionSnapshot?: PreviousSnapshot;
}): z.infer<typeof completionSnapshotFormSchema> => {
  const buildSnapshotAttribute = (itemId: number): CompletionSnapshotItem => ({
    item_id: itemId,
    completion_percentage: findPreviousCompletionPercentage(
      itemId,
      previousCompletionSnapshot
    ).toString(),
  });

  return {
    description: "",
    completion_snapshot_attributes: itemGroups.flatMap((group) =>
      group.grouped_items.map((item) => buildSnapshotAttribute(item.id))
    ),
  };
};

type CompletionSnapshotItemAttribute = {
  item_id: number;
  completion_percentage: string;
};

const computeItemValue = (item: Item, completionPercentage: string): number => {
  return (
    (Number(completionPercentage) / 100) * item.unit_price_cents * item.quantity
  );
};

const findCompletionPercentage = (
  itemId: number,
  completionSnapshots: CompletionSnapshotItemAttribute[]
): string => {
  return (
    completionSnapshots.find(({ item_id }) => item_id === itemId)
      ?.completion_percentage || "0"
  );
};

const computeCompletionSnapShotTotalCents = (
  completion_snapshot_items_attributes: CompletionSnapshotItemAttribute[],
  items: (ItemGroup | Item)[]
): number => {
  const computeValues = (item: ItemGroup | Item): number[] => {
    if ("grouped_items" in item) {
      return item.grouped_items.map((groupedItem) =>
        computeItemValue(
          groupedItem,
          findCompletionPercentage(
            groupedItem.id,
            completion_snapshot_items_attributes
          )
        )
      );
    }
    return [
      computeItemValue(
        item,
        findCompletionPercentage(item.id, completion_snapshot_items_attributes)
      ),
    ];
  };

  return items
    .flatMap(computeValues)
    .reduce((total, value) => total + value, 0);
};

export {
  buildInitialValues,
  findPreviousCompletionPercentage,
  computeCompletionSnapShotTotalCents,
};
