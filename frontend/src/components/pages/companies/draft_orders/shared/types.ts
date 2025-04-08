import { paths } from "@/lib/openapi-fetch-schemas";

type DraftOrderExtended =
  paths["/api/v1/organization/draft_orders/{id}"]["get"]["responses"]["200"]["content"]["application/json"]["result"];

type UpdatDraftOrderBody = NonNullable<
  paths["/api/v1/organization/draft_orders/{id}"]["put"]["requestBody"]
>["content"]["application/json"];

export type { DraftOrderExtended, UpdatDraftOrderBody };
