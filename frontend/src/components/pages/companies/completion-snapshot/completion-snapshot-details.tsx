import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { Api } from "@/lib/openapi-fetch-query-client";
import { ProjectVersion } from "../project-versions/shared/types";
import { CompletionSnapshotItem } from "./shared/types";
import { GroupedItemsDetails } from "./private/grouped-items-details";
import { useTranslation } from "react-i18next";

const LoadingDetails = () => <Skeleton className="w-full h-4" />;

const UngroupedItemsDetails = () => "UngroupedItemsDetails";

const LoadedDetails = ({
  completionSnapshotData,
}: {
  completionSnapshotData: {
    completion_snapshot_items: Array<CompletionSnapshotItem>;
    project_version: ProjectVersion;
  };
}) => {
  return completionSnapshotData.project_version.ungrouped_items.length > 0 ? (
    <UngroupedItemsDetails />
  ) : (
    <GroupedItemsDetails
      itemGroups={completionSnapshotData.project_version.item_groups}
      completionSnapshotItems={completionSnapshotData.completion_snapshot_items}
    />
  );
};

const CompletionSnapshotDetails = ({
  completionSnapshotId,
}: {
  completionSnapshotId: number;
}) => {
  const { data } = Api.useQuery(
    "get",
    "/api/v1/organization/completion_snapshots/{id}",
    { params: { path: { id: completionSnapshotId } } }
  );
  const { t } = useTranslation();
  return (
    <Card>
      <CardHeader>
        <CardTitle>
          {t("pages.companies.completion_snapshot.grouped_items_details.title")}
        </CardTitle>
      </CardHeader>
      <CardContent>
        {data == undefined ? (
          <LoadingDetails />
        ) : (
          <LoadedDetails completionSnapshotData={data.result} />
        )}
      </CardContent>
    </Card>
  );
};

export { CompletionSnapshotDetails };
