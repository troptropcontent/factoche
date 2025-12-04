import { paths } from "@/lib/openapi-fetch-schemas";

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

type ProjectVersionCompact =
  paths["/api/v1/organization/companies/{company_id}/invoices"]["get"]["responses"]["200"]["content"]["application/json"]["meta"]["order_versions"][number];
type ProjectVersionExtended =
  paths["/api/v1/organization/project_versions/{id}"]["get"]["responses"]["200"]["content"]["application/json"]["result"];

export type {
  Item,
  ItemGroup,
  ProjectVersion,
  ProjectVersionCompact,
  ProjectVersionExtended,
};
