import { paths } from "@/lib/openapi-fetch-schemas";
import { QuoteExtended, UpdateQuoteBody } from "../../quotes/shared/type";
import {
  DraftOrderExtended,
  UpdatDraftOrderBody,
} from "../../draft_orders/shared/types";
import { OrderExtended, UpdatOrderBody } from "../../orders/shared/types";

type OrderCompact =
  paths["/api/v1/organization/companies/{company_id}/invoices"]["get"]["responses"]["200"]["content"]["application/json"]["meta"]["orders"][number];

type ProjectExtended = QuoteExtended | DraftOrderExtended | OrderExtended;

type UpdateProjectBody = UpdateQuoteBody | UpdatOrderBody | UpdatDraftOrderBody;

export type { OrderCompact, ProjectExtended, UpdateProjectBody };
