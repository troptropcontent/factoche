import {
  Table,
  TableBody,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Api } from "@/lib/openapi-fetch-query-client";

import { useTranslation } from "react-i18next";
import { DraftOrdersTableRow } from "./draft-orders-table-row";

const DraftOrdersTable = ({ companyId }: { companyId: string }) => {
  const { t } = useTranslation();
  const { data: draftOrders = [] } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/draft_orders",
    { params: { path: { company_id: Number(companyId) } } },
    { select: ({ results }) => results }
  );
  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>
            {t("pages.companies.orders.index.tabs.draft.columns.number")}
          </TableHead>
          <TableHead>
            {t("pages.companies.orders.index.tabs.draft.columns.name")}
          </TableHead>
          <TableHead>
            {t("pages.companies.orders.index.tabs.draft.columns.client")}
          </TableHead>
          <TableHead>
            {t("pages.companies.orders.index.tabs.draft.columns.amount")}
          </TableHead>
          <TableHead>
            {t("pages.companies.orders.index.tabs.draft.columns.status")}
          </TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {draftOrders.map((draftOrder) => (
          <DraftOrdersTableRow draftOrder={draftOrder} companyId={companyId} />
        ))}
      </TableBody>
    </Table>
  );
};

export { DraftOrdersTable };
