import { Badge } from "@/components/ui/badge";
import { useTranslation } from "react-i18next";

interface QuoteStatusBadgeProps {
  posted: boolean;
}

const getStatusColor = (posted: boolean) => {
  return posted ? "bg-green-500" : "bg-gray-500";
};

export function QuoteStatusBadge({ posted }: QuoteStatusBadgeProps) {
  const { t } = useTranslation();
  return (
    <Badge className={`${getStatusColor(posted)} text-white`}>
      {t(`pages.companies.quotes.status.${posted ? "posted" : "draft"}`)}
    </Badge>
  );
}
