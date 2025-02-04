type Item = {
  name: string;
  description?: string | null;
  position: number;
  id: number;
  quantity: number;
  unit_price_cents: number;
};

type ItemGroup = {
  name: string;
  description?: string | null;
  position: number;
  grouped_items: Item[];
};

type ProjectVersion = {
  number: number;
  ungrouped_items: Item[];
  item_groups: ItemGroup[];
};

export type { Item, ItemGroup, ProjectVersion };
