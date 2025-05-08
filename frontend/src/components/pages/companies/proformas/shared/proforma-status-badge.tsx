import { Check, AlertCircle, Pen } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { useTranslation } from "react-i18next";
import { ProformaCompact } from "./types";

interface ProformaStatusBadgeProps {
  status: ProformaCompact["status"];
  className?: string;
}

export function ProformaStatusBadge({
  status,
  className,
}: ProformaStatusBadgeProps) {
  const { t } = useTranslation();
  switch (status) {
    case "posted":
      return (
        <Badge className={`bg-green-500 hover:bg-green-600 ${className}`}>
          <Check className="mr-1 h-3 w-3" />{" "}
          {t(
            "pages.companies.projects.invoices.index.tabs.proforma.status.posted"
          )}
        </Badge>
      );
    case "draft":
      return (
        <Badge className={`bg-yellow-500 hover:bg-yellow-600 ${className}`}>
          <Pen className="mr-1 h-3 w-3" />{" "}
          {t(
            "pages.companies.projects.invoices.index.tabs.proforma.status.draft"
          )}
        </Badge>
      );
    case "voided":
      return (
        <Badge className={`bg-red-500 hover:bg-red-600 ${className}`}>
          <AlertCircle className="mr-1 h-3 w-3" />{" "}
          {t(
            "pages.companies.projects.invoices.index.tabs.proforma.status.voided"
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
