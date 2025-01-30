import { Badge } from "@/components/ui/badge";
import { useTranslation } from "react-i18next";

const getStatusColor = (status: string) => {
  switch (status) {
    case "draft":
      return "bg-gray-500 hover:bg-gray-600";
    case "invoiced":
      return "bg-green-500 hover:bg-green-600";
    case "cancelled":
      return "bg-red-500 hover:bg-red-600";
    default:
      return "bg-gray-500 hover:bg-gray-600";
  }
};

const CompletionSnapshotStatusBadge = ({ status }: { status: string }) => {
  const { t } = useTranslation();

  return (
    <Badge className={`${getStatusColor(status)} text-white`}>
      {t(`pages.companies.completion_snapshot.status.${status}`)}
    </Badge>
  );
};

export { CompletionSnapshotStatusBadge };
