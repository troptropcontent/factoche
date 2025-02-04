import { Item, ProjectVersion } from "../../project-versions/shared/types";
import { computeItemTotalCents } from "../../project-versions/shared/utils";
import { CompletionSnapshotItem } from "./types";

const computeCompletionSnapShotTotalCents = (completionSnapshotData: {
  completion_snapshot_items: Array<CompletionSnapshotItem>;
  project_version: ProjectVersion;
}): number => {
  const findPercentageAndComputeItemValueCents = (
    item: (typeof completionSnapshotData)["project_version"]["ungrouped_items"][number]
  ): number => {
    const percentage =
      completionSnapshotData.completion_snapshot_items.find(
        ({ item_id }) => item_id === item.id
      )?.completion_percentage || "0";

    return (Number(percentage) / 100) * item.unit_price_cents * item.quantity;
  };

  const allItems = [
    ...completionSnapshotData.project_version.ungrouped_items,
    ...completionSnapshotData.project_version.item_groups.flatMap(
      (item_group) => item_group.grouped_items
    ),
  ];

  return allItems.reduce(
    (total, item) => total + findPercentageAndComputeItemValueCents(item),
    0
  );
};

const computeCompletionSnapshotItemValueCents = (
  itemId: number,
  completionSnapshotItems: Array<CompletionSnapshotItem>,
  projectVersionData: ProjectVersion
) => {
  const completionPercentage = completionSnapshotItems.find(
    ({ item_id }) => itemId === item_id
  );

  const item =
    projectVersionData.ungrouped_items.find(({ id }) => id === itemId) ||
    projectVersionData.item_groups
      .flatMap((itemGroup) => itemGroup.grouped_items)
      .find(({ id }) => itemId === id);

  return completionPercentage && item
    ? (Number(completionPercentage) / 100) *
        item.quantity *
        item.unit_price_cents
    : 0;
};

const sortAndFilterCompletionSnapshots = <T extends { created_at: string }>(
  snapshots: Array<T>,
  referenceDate: string
) => {
  return snapshots
    .sort((a, b) => Date.parse(b.created_at) - Date.parse(a.created_at))
    .filter(
      (snapshot) => Date.parse(snapshot.created_at) < Date.parse(referenceDate)
    );
};

const computeItemCompletionSnapshotValueCents = (
  item: Item,
  completionSnapshotItems: CompletionSnapshotItem[]
) => {
  const completionSnapshotItem = completionSnapshotItems.find(
    (completionSnapshotItem) => completionSnapshotItem.item_id === item.id
  );

  if (completionSnapshotItem == undefined) {
    return 0;
  }

  const percentage = Number(completionSnapshotItem.completion_percentage);

  return (percentage / 100) * computeItemTotalCents(item);
};

export {
  computeCompletionSnapShotTotalCents,
  sortAndFilterCompletionSnapshots,
  computeCompletionSnapshotItemValueCents,
  computeItemCompletionSnapshotValueCents,
};
