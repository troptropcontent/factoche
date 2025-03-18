import { Item } from "./types";

const computeProjectVersionTotal = (projectVersionData: {
  ungrouped_items: Item[];
  item_groups: {
    grouped_items: Item[];
  }[];
}) => {
  const items = [
    ...projectVersionData.item_groups.flatMap((item) => item.grouped_items),
    ...projectVersionData.ungrouped_items,
  ];
  return items.reduce((total, current) => total + computeItemTotal(current), 0);
};

const computeItemTotal = (item: Item) => {
  return item.quantity * item.unit_price_amount;
};

const computeProjectVersionTotalAmount = ({ items }: { items: Item[] }) => {
  return items.reduce((total, current) => total + computeItemTotal(current), 0);
};

export {
  computeProjectVersionTotal,
  computeItemTotal,
  computeProjectVersionTotalAmount,
};
