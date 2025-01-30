type Item = { quantity: number; unit_price_cents: number };
type ProjectVersionData = {
  ungrouped_items: Item[];
  item_groups: {
    grouped_items: Item[];
  }[];
};

const computeProjectVersionTotalCents = (
  projectVersionData: ProjectVersionData
) => {
  const items = [
    ...projectVersionData.item_groups.flatMap((item) => item.grouped_items),
    ...projectVersionData.ungrouped_items,
  ];
  return items.reduce(
    (total, current) => total + current.quantity * current.unit_price_cents,
    0
  );
};

export { computeProjectVersionTotalCents };
