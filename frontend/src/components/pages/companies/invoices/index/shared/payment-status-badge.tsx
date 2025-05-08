import { Check, Clock, AlertCircle } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { InvoiceCompact } from "../../shared/types";
import { useTranslation } from "react-i18next";

interface PaymentStatusBadgeProps {
  status: InvoiceCompact["payment_status"];
  className?: string;
}

export function PaymentStatusBadge({
  status,
  className,
}: PaymentStatusBadgeProps) {
  const { t } = useTranslation();
  switch (status) {
    case "paid":
      return (
        <Badge className={`bg-green-500 hover:bg-green-600 ${className}`}>
          <Check className="mr-1 h-3 w-3" />{" "}
          {t(
            "pages.companies.projects.invoices.index.tabs.table.columns.payment_status.paid"
          )}
        </Badge>
      );
    case "pending":
      return (
        <Badge className={`bg-yellow-500 hover:bg-yellow-600 ${className}`}>
          <Clock className="mr-1 h-3 w-3" />{" "}
          {t(
            "pages.companies.projects.invoices.index.tabs.table.columns.payment_status.pending"
          )}
        </Badge>
      );
    case "overdue":
      return (
        <Badge className={`bg-red-500 hover:bg-red-600 ${className}`}>
          <AlertCircle className="mr-1 h-3 w-3" />{" "}
          {t(
            "pages.companies.projects.invoices.index.tabs.table.columns.payment_status.overdue"
          )}
        </Badge>
      );
    default:
      return (
        <Badge variant="outline" className={className}>
          Unknown
        </Badge>
      );
  }
}
