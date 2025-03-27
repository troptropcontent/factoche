import { paths } from "@/lib/openapi-fetch-schemas";

type OrderCompact =
  paths["/api/v1/organization/companies/{company_id}/invoices"]["get"]["responses"]["200"]["content"]["application/json"]["meta"]["orders"][number];

export type { OrderCompact };
