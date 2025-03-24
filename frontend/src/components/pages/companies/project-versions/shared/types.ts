type Item = {
  name: string;
  description?: string | null;
  position: number;
  id: number;
  original_item_uuid: string;
  quantity: number;
  unit_price_amount: number;
};

type ItemGroup = {
  id: number;
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
