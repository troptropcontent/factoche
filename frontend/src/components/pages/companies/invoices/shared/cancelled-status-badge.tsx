import { Badge } from "@/components/ui/badge";
import { useTranslation } from "react-i18next";

const CancelledInvoiceBadge = ({ className }: { className?: string }) => {
  const { t } = useTranslation();
  return (
    <Badge
      variant="outline"
      className={`ml-2 border-red-500 text-red-500 ${className}`}
    >
      {t(
        "pages.companies.projects.invoices.index.tabs.invoices.status.cancelled"
      )}
    </Badge>
  );
};

export { CancelledInvoiceBadge };
