const computeProjectVersionTotalCents = (projectVersionData: {
  ungrouped_items: { quantity: number; unit_price_cents: number }[];
  item_groups: {
    grouped_items: { quantity: number; unit_price_cents: number }[];
  }[];
}) => {
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
