import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { Api } from "@/lib/openapi-fetch-query-client";
import { ProjectVersion } from "../project-versions/shared/types";
import { CompletionSnapshotItem } from "./shared/types";
import { useTranslation } from "react-i18next";
import { GroupedItemsDetailsNew } from "./private/grouped-items-details-new";

const LoadingDetails = () => <Skeleton className="w-full h-4" />;

const UngroupedItemsDetails = () => "UngroupedItemsDetails";

const LoadedDetails = ({
  completionSnapshotData,
}: {
  completionSnapshotData: {
    completion_snapshot_items: Array<CompletionSnapshotItem>;
    project_version: ProjectVersion;
    invoice: object;
  };
}) => {
  return completionSnapshotData.project_version.ungrouped_items.length > 0 ? (
    <UngroupedItemsDetails />
  ) : (
    <GroupedItemsDetailsNew
      itemGroups={completionSnapshotData.project_version.item_groups}
      completionSnapshotItems={completionSnapshotData.completion_snapshot_items}
      invoice={completionSnapshotData.invoice}
    />
  );
};

const CompletionSnapshotDetailsNew = ({
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

export { CompletionSnapshotDetailsNew };
