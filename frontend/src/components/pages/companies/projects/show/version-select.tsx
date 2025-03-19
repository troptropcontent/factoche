import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Api } from "@/lib/openapi-fetch-query-client";

import { useTranslation } from "react-i18next";

const VersionSelect = ({
  routeParams: { companyId, orderId },
  versionId,
  onValueChange,
}: {
  routeParams: { companyId: number; orderId: number };
  versionId: number;
  onValueChange: (value: string) => void;
}) => {
  const { t } = useTranslation();
  const { data: { results: versions } = { results: [] } } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/orders/{order_id}/versions",
    {
      params: {
        path: { company_id: companyId, order_id: orderId },
      },
    }
  );

  return (
    <Select value={versionId.toString()} onValueChange={onValueChange}>
      <SelectTrigger className="w-auto">
        <SelectValue placeholder="Select a version" />
      </SelectTrigger>
      <SelectContent>
        {versions.map((version) => (
          <SelectItem key={version.id} value={version.id.toString()}>
            {t("pages.companies.projects.show.version_label", {
              number: version.number,
              createdAt: Date.parse(version.created_at),
            })}
          </SelectItem>
        ))}
      </SelectContent>
    </Select>
  );
};

export { VersionSelect };
