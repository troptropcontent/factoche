import {
  Table,
  TableBody,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Api } from "@/lib/openapi-fetch-query-client";

import { useTranslation } from "react-i18next";
import { OrdersTableRow } from "./orders-table-row";

const OrdersTable = ({ companyId }: { companyId: string }) => {
  const { t } = useTranslation();
  const { data: orders = [] } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/orders",
    { params: { path: { company_id: Number(companyId) } } },
    { select: ({ results }) => results }
  );
  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>
            {t("pages.companies.orders.index.tabs.posted.columns.number")}
          </TableHead>
          <TableHead>
            {t("pages.companies.orders.index.tabs.posted.columns.name")}
          </TableHead>
          <TableHead>
            {t("pages.companies.orders.index.tabs.posted.columns.client")}
          </TableHead>
          <TableHead>
            {t("pages.companies.orders.index.tabs.posted.columns.total_amount")}
          </TableHead>
          <TableHead>
            {t(
              "pages.companies.orders.index.tabs.posted.columns.invoiced_amount"
            )}
          </TableHead>
          <TableHead>
            {t(
              "pages.companies.orders.index.tabs.posted.columns.remaining_amount"
            )}
          </TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {orders.map((order) => (
          <OrdersTableRow order={order} companyId={companyId} />
        ))}
      </TableBody>
    </Table>
  );
};

export { OrdersTable };
