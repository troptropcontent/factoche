import { Badge } from "@/components/ui/badge";
import { useTranslation } from "react-i18next";

const getStatusColor = (status: string) => {
  switch (status) {
    case "draft":
      return "bg-gray-500 hover:bg-gray-600";
    case "posted":
      return "bg-green-500 hover:bg-green-600";
    case "cancelled":
      return "bg-red-500 hover:bg-red-600";
    default:
      return "bg-gray-500 hover:bg-gray-600";
  }
};

const StatusBadge = ({ status }: { status: string }) => {
  const { t } = useTranslation();

  return (
    <Badge className={`${getStatusColor(status)} text-white h-fit`}>
      {t(
        `pages.companies.projects.invoices.completion_snapshot.show.status.${status}`
      )}
    </Badge>
  );
};

export { StatusBadge };
