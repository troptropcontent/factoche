const computeCompletionSnapShotTotalCents = (completionSnapshotData: {
  completion_snapshot_items: {
    item_id: number;
    completion_percentage: string;
  }[];
  project_version: {
    ungrouped_items: {
      id: number;
      quantity: number;
      unit_price_cents: number;
    }[];
    item_groups: {
      grouped_items: {
        id: number;
        quantity: number;
        unit_price_cents: number;
      }[];
    }[];
  };
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

const sortAndFilterCompletionSnapshots = (
  snapshots: Array<{ id: number; created_at: string }>,
  referenceDate: string
) => {
  return snapshots
    .sort((a, b) => Date.parse(b.created_at) - Date.parse(a.created_at))
    .filter(
      (snapshot) => Date.parse(snapshot.created_at) < Date.parse(referenceDate)
    );
};

export {
  computeCompletionSnapShotTotalCents,
  sortAndFilterCompletionSnapshots,
};
