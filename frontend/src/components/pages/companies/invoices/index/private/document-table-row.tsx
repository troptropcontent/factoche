import { TableCell, TableRow } from "@/components/ui/table";
import { StatusBadge } from "../../private/status-badge";
import { Button } from "@/components/ui/button";
import { Link } from "@tanstack/react-router";
import { Download, Eye, Loader2 } from "lucide-react";
import { InvoiceCompact } from "../../shared/types";
import { ProjectVersionCompact } from "../../../project-versions/shared/types";
import { OrderCompact } from "../../../projects/shared/types";
import { useTranslation } from "react-i18next";
import { findOrder } from "./utils";

const DocumentTableRow = ({
  companyId,
  document,
  orderVersions,
  orders,
}: {
  companyId: string;
  document: InvoiceCompact;
  orderVersions: ProjectVersionCompact[];
  orders: OrderCompact[];
}) => {
  const { t } = useTranslation();

  const order = findOrder(document, orderVersions, orders);
  if (order === undefined) {
    throw "order could not be found in the metada, this is likely a bug";
  }
  return (
    <TableRow key={document.id}>
      <TableCell className="font-medium">{document.number}</TableCell>
      <TableCell>{order.client.name}</TableCell>
      <TableCell>{order.name}</TableCell>
      <TableCell>
        {t("common.date", {
          date: Date.parse(document.issue_date),
        })}
      </TableCell>
      <TableCell>
        {t("common.number_in_currency", {
          amount: document.total_amount,
        })}
      </TableCell>
      <TableCell>
        <StatusBadge status={document.status} />
      </TableCell>
      <TableCell className="text-right">
        <div className="flex justify-end gap-2">
          <Button variant="outline" size="sm" asChild>
            <Link
              to={"/companies/$companyId/invoices/$invoiceId"}
              params={{
                companyId: companyId,
                invoiceId: document.id.toString(),
              }}
            >
              <Eye />
            </Link>
          </Button>
          <Button asChild variant="outline" size="sm">
            {document.pdf_url ? (
              <Link
                to={`${import.meta.env.VITE_API_BASE_URL}${document.pdf_url}`}
                target="_blank"
              >
                <Download />
              </Link>
            ) : (
              <Link disabled>
                <Loader2 className="animate-spin" />
              </Link>
            )}
          </Button>
        </div>
      </TableCell>
    </TableRow>
  );
};

export { DocumentTableRow };
