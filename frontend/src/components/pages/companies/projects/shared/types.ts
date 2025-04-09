import { paths } from "@/lib/openapi-fetch-schemas";
import { QuoteExtended, UpdateQuoteBody } from "../../quotes/shared/type";
import {
  DraftOrderExtended,
  UpdatDraftOrderBody,
} from "../../draft_orders/shared/types";
import { OrderExtended, UpdatOrderBody } from "../../orders/shared/types";
import { QUOTE_TYPE_KEY } from "../../quotes/shared/constants";
import { DRAFT_ORDER_TYPE_KEY } from "../../draft_orders/shared/constants";
import { ORDER_TYPE_KEY } from "../../orders/shared/constants";

type OrderCompact =
  paths["/api/v1/organization/companies/{company_id}/invoices"]["get"]["responses"]["200"]["content"]["application/json"]["meta"]["orders"][number];

type ProjectExtended = QuoteExtended | DraftOrderExtended | OrderExtended;

type UpdateProjectBody = UpdateQuoteBody | UpdatOrderBody | UpdatDraftOrderBody;

type ProjectTypeKey =
  | typeof QUOTE_TYPE_KEY
  | typeof DRAFT_ORDER_TYPE_KEY
  | typeof ORDER_TYPE_KEY;

export type {
  OrderCompact,
  ProjectExtended,
  UpdateProjectBody,
  ProjectTypeKey,
};
