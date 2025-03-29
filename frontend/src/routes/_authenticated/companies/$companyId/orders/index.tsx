import { Layout } from "@/components/pages/companies/layout";
import { OrderCompact } from "@/components/pages/companies/projects/shared/types";
import { Skeleton } from "@/components/ui/skeleton";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Api } from "@/lib/openapi-fetch-query-client";
import { createFileRoute, useNavigate } from "@tanstack/react-router";

import { useTranslation } from "react-i18next";

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/orders/"
)({
  component: RouteComponent,
});

const OrdersTableRow = ({
  order,
  companyId,
}: {
  order: OrderCompact;
  companyId: string;
}) => {
  const navigate = useNavigate();
  const { t } = useTranslation();
  const { data: invoicedAmount } = Api.useQuery(
    "get",
    "/api/v1/organization/orders/{id}/invoiced_items",
    { params: { path: { id: order.id } } },
    {
      select: (data) =>
        data.results.reduce(
          (prev, { invoiced_amount }) => prev + Number(invoiced_amount),
          0
        ),
    }
  );

  const handleRowClick = (orderId: number) => {
    navigate({
      to: "/companies/$companyId/orders/$orderId",
      params: { companyId: companyId, orderId: orderId.toString() },
    });
  };
  return (
    <TableRow
      key={order.id}
      onClick={() => handleRowClick(order.id)}
      className="cursor-pointer hover:bg-gray-100 transition-colors"
      role="link"
      tabIndex={0}
      onKeyDown={(e) => {
        if (e.key === "Enter" || e.key === " ") {
          e.preventDefault();
          handleRowClick(order.id);
        }
      }}
    >
      <TableCell className="font-medium">{order.name}</TableCell>
      <TableCell>{order.client.name}</TableCell>
      <TableCell>
        {t("common.number_in_currency", {
          amount: parseFloat(order.last_version.total_amount),
        })}
      </TableCell>
      <TableCell>
        {invoicedAmount !== undefined ? (
          t("common.number_in_currency", {
            amount: invoicedAmount,
          })
        ) : (
          <Skeleton className="w-full h-4" />
        )}
      </TableCell>
      <TableCell>
        {invoicedAmount !== undefined ? (
          t("common.number_in_currency", {
            amount:
              parseFloat(order.last_version.total_amount) - invoicedAmount,
          })
        ) : (
          <Skeleton className="w-full h-4" />
        )}
      </TableCell>
    </TableRow>
  );
};

function RouteComponent() {
  const { companyId } = Route.useParams();
  const { t } = useTranslation();
  const { data: orders = [] } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/orders",
    { params: { path: { company_id: Number(companyId) } } },
    { select: ({ results }) => results }
  );

  return (
    <Layout.Root>
      <Layout.Header>
        <div className="flex flex-grow justify-between items-center">
          <h1 className="text-3xl font-bold">
            {t("pages.companies.projects.index.title")}
          </h1>
        </div>
      </Layout.Header>
      <Layout.Content>
        <div className="container mx-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>
                  {t("pages.companies.projects.index.table.columns.name")}
                </TableHead>
                <TableHead>
                  {t("pages.companies.projects.index.table.columns.client")}
                </TableHead>
                <TableHead>
                  {t(
                    "pages.companies.projects.index.table.columns.total_amount"
                  )}
                </TableHead>
                <TableHead>
                  {t(
                    "pages.companies.projects.index.table.columns.invoiced_amount"
                  )}
                </TableHead>
                <TableHead>
                  {t(
                    "pages.companies.projects.index.table.columns.remaining_amount"
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
        </div>
      </Layout.Content>
    </Layout.Root>
  );
}
