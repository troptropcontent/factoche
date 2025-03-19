import { Badge } from "@/components/ui/badge";
import { useTranslation } from "react-i18next";

interface QuoteStatusBadgeProps {
  status: string;
}

const getStatusColor = (status: string) => {
  switch (status) {
    case "draft":
      return "bg-gray-500";
    case "validated":
      return "bg-green-500";
    default:
      return "bg-gray-500";
  }
};

export function QuoteStatusBadge({ status }: QuoteStatusBadgeProps) {
  const { t } = useTranslation();
  return (
    <Badge className={`${getStatusColor(status)} text-white`}>
      {t(`pages.companies.quotes.status.${status}`)}
    </Badge>
  );
}
