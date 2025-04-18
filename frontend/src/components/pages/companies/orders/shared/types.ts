import { paths } from "@/lib/openapi-fetch-schemas";

type OrderExtended =
  paths["/api/v1/organization/orders/{id}"]["get"]["responses"]["200"]["content"]["application/json"]["result"];

type OrderCompact =
  paths["/api/v1/organization/companies/{company_id}/orders"]["get"]["responses"]["200"]["content"]["application/json"]["results"][number];

type UpdatOrderBody = NonNullable<
  paths["/api/v1/organization/orders/{id}"]["put"]["requestBody"]
>["content"]["application/json"];

export type { OrderExtended, UpdatOrderBody, OrderCompact };
