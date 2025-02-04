import { Api } from "@/lib/openapi-fetch-query-client";
import {
  computeCompletionSnapShotTotalCents,
  sortAndFilterCompletionSnapshots,
} from "./utils";

const useCompletionSnapshotTotalCents = (completionSnapshotId: number) => {
  const { data } = Api.useQuery(
    "get",
    "/api/v1/organization/completion_snapshots/{id}",
    { params: { path: { id: completionSnapshotId } } }
  );

  if (data == undefined) {
    return {
      completionSnapshotTotalCents: undefined,
      isLoading: true as const,
    };
  }

  return {
    completionSnapshotTotalCents: computeCompletionSnapShotTotalCents(
      data.result
    ),
    isLoading: false as const,
  };
};

const usePreviousCompletionSnapshotTotalCents = (
  completionSnapshotId: number
) => {
  const { data: completionSnapshotData } = Api.useQuery(
    "get",
    "/api/v1/organization/completion_snapshots/{id}",
    { params: { path: { id: completionSnapshotId } } }
  );

  const completionSnapshotDataLoaded = completionSnapshotData != undefined;

  const { data: completionSnapshotsData } = Api.useQuery(
    "get",
    "/api/v1/organization/completion_snapshots",
    {
      params: {
        query: {
          filter: {
            project_version_id:
              completionSnapshotData?.result.project_version.id,
          },
        },
      },
    },
    { enabled: completionSnapshotData != undefined }
  );

  const completionSnapshotsDataLoaded = completionSnapshotsData != undefined;

  const previousCompletionData =
    completionSnapshotDataLoaded && completionSnapshotsDataLoaded
      ? sortAndFilterCompletionSnapshots(
          completionSnapshotsData.results,
          completionSnapshotData?.result.created_at
        )[0]
      : undefined;

  const { data: previousCompletionSnapshotData } = Api.useQuery(
    "get",
    "/api/v1/organization/completion_snapshots/{id}",
    // @ts-expect-error previousCompletionData.id can be undefined but the API call is guarded by enabled
    { params: { path: { id: previousCompletionData?.id } } },
    { enabled: previousCompletionData != undefined }
  );

  const previousCompletionSnapshotDataLoaded =
    previousCompletionData === undefined
      ? true
      : previousCompletionSnapshotData != undefined;

  if (
    completionSnapshotDataLoaded &&
    completionSnapshotsDataLoaded &&
    previousCompletionSnapshotDataLoaded
  ) {
    return {
      previousCompletionSnapshotTotalCents: previousCompletionSnapshotData
        ? computeCompletionSnapShotTotalCents(
            previousCompletionSnapshotData.result
          )
        : 0,
      isLoading: false as const,
    };
  }

  return {
    previousCompletionSnapshotTotalCents: undefined,
    isLoading: true as const,
  };
};

export {
  useCompletionSnapshotTotalCents,
  usePreviousCompletionSnapshotTotalCents,
};
