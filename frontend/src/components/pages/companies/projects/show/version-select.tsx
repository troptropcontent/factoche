import { Card, CardHeader, CardContent, CardTitle } from "@/components/ui/card";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

import { useTranslation } from "react-i18next";

const VersionSelect = ({
  versionId,
  onValueChange,
  versions,
}: {
  versionId: string;
  onValueChange: (value: string) => void;
  versions: { id: number; number: number; created_at: string }[];
}) => {
  const { t } = useTranslation();

  return (
    <Card className="mt-6">
      <CardHeader>
        <CardTitle>
          {t("pages.companies.projects.show.project_versions")}
        </CardTitle>
      </CardHeader>
      <CardContent>
        <Select value={versionId} onValueChange={onValueChange}>
          <SelectTrigger className="w-full">
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
      </CardContent>
    </Card>
  );
};

export { VersionSelect };
