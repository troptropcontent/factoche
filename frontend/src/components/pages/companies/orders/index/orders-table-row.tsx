import { TableCell } from "@/components/ui/table";

import { useTranslation } from "react-i18next";

import { useNavigate } from "@tanstack/react-router";
import { OrderCompact } from "../shared/types";
import { Api } from "@/lib/openapi-fetch-query-client";
import { TableRow } from "@/components/ui/table";
import { Skeleton } from "@/components/ui/skeleton";

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
      <TableCell className="font-medium">{order.number}</TableCell>
      <TableCell>{order.name}</TableCell>
      <TableCell>{order.client.name}</TableCell>
      <TableCell>
        {t("common.number_in_currency", {
          amount: parseFloat(order.last_version.total_excl_tax_amount),
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
              parseFloat(order.last_version.total_excl_tax_amount) -
              invoicedAmount,
          })
        ) : (
          <Skeleton className="w-full h-4" />
        )}
      </TableCell>
    </TableRow>
  );
};

export { OrdersTableRow };
