import { paths } from "@/lib/openapi-fetch-schemas";

type ProformaExtended =
  paths["/api/v1/organization/proformas/{id}"]["get"]["responses"]["200"]["content"]["application/json"]["result"];

type ProformaCompact =
  paths["/api/v1/organization/companies/{company_id}/proformas"]["get"]["responses"]["200"]["content"]["application/json"]["results"][number];

export type { ProformaExtended, ProformaCompact };
