import { paths } from "@/lib/openapi-fetch-schemas";

interface Line {
  holder_id: string;
  excl_tax_amount: string;
}
type InvoiceCompact =
  paths["/api/v1/organization/companies/{company_id}/invoices"]["get"]["responses"]["200"]["content"]["application/json"]["results"][number];

export type { Line, InvoiceCompact };
