import { paths } from "@/lib/openapi-fetch-schemas";

type QuoteExtended =
  paths["/api/v1/organization/quotes/{id}"]["get"]["responses"]["200"]["content"]["application/json"]["result"];

type UpdateQuoteBody = NonNullable<
  paths["/api/v1/organization/quotes/{id}"]["put"]["requestBody"]
>["content"]["application/json"];

export type { QuoteExtended, UpdateQuoteBody };
