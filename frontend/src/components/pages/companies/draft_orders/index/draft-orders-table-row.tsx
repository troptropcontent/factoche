import { TableCell } from "@/components/ui/table";

import { useTranslation } from "react-i18next";

import { useNavigate } from "@tanstack/react-router";
import { DraftOrderCompact } from "../shared/types";
import { TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";

const DraftOrdersTableRow = ({
  draftOrder,
  companyId,
}: {
  draftOrder: DraftOrderCompact;
  companyId: string;
}) => {
  const navigate = useNavigate();
  const { t } = useTranslation();

  const handleRowClick = (draftOrderId: number) => {
    navigate({
      to: "/companies/$companyId/draft_orders/$draftOrderId",
      params: { companyId: companyId, draftOrderId: draftOrderId.toString() },
    });
  };
  return (
    <TableRow
      key={draftOrder.id}
      onClick={() => handleRowClick(draftOrder.id)}
      className="cursor-pointer hover:bg-gray-100 transition-colors"
      role="link"
      tabIndex={0}
      onKeyDown={(e) => {
        if (e.key === "Enter" || e.key === " ") {
          e.preventDefault();
          handleRowClick(draftOrder.id);
        }
      }}
    >
      <TableCell className="font-medium">{draftOrder.number}</TableCell>
      <TableCell>{draftOrder.name}</TableCell>
      <TableCell>{draftOrder.client.name}</TableCell>
      <TableCell>
        {t("common.number_in_currency", {
          amount: parseFloat(draftOrder.last_version.total_amount),
        })}
      </TableCell>
      <TableCell>
        <Badge
          className={`${draftOrder.posted ? "bg-green-500" : "bg-gray-500"} text-white`}
        >
          {t(
            `pages.companies.draft_orders.badge.status.${draftOrder.posted ? "posted" : "draft"}`
          )}
        </Badge>
      </TableCell>
    </TableRow>
  );
};

export { DraftOrdersTableRow };
