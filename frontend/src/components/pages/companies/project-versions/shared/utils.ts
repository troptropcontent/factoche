import { Item } from "./types";

const computeProjectVersionTotalCents = (projectVersionData: {
  ungrouped_items: Item[];
  item_groups: {
    grouped_items: Item[];
  }[];
}) => {
  const items = [
    ...projectVersionData.item_groups.flatMap((item) => item.grouped_items),
    ...projectVersionData.ungrouped_items,
  ];
  return items.reduce(
    (total, current) => total + computeItemTotalCents(current),
    0
  );
};

const computeItemTotalCents = (item: Item) => {
  return item.quantity * item.unit_price_cents;
};

const computeProjectVersionTotalAmount = ({ items }: { items: Item[] }) => {
  return items.reduce(
    (total, current) => total + computeItemTotalCents(current) / 100,
    0
  );
};

export {
  computeProjectVersionTotalCents,
  computeItemTotalCents,
  computeProjectVersionTotalAmount,
};
