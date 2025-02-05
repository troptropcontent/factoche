import { Button } from "@/components/ui/button";
import { Link } from "@tanstack/react-router";

const EditButton = ({
  routeParams,
}: {
  routeParams: {
    companyId: string;
    projectId: string;
    completionSnapshotId: string;
  };
}) => {
  return (
    <Button asChild variant="outline">
      <Link
        to="/companies/$companyId/projects/$projectId/completion_snapshots/$completionSnapshotId/edit"
        params={routeParams}
      >
        Edit
      </Link>
    </Button>
  );
};

const CompletionSnapshotActions = ({
  completionSnapshotStatus,
  routeParams: { companyId, completionSnapshotId, projectId },
}: {
  completionSnapshotStatus: "draft" | "invoiced" | "cancelled";
  routeParams: {
    companyId: number;
    projectId: number;
    completionSnapshotId: number;
  };
}) => {
  return (
    <div className="flex flex-col">
      {completionSnapshotStatus === "draft" && (
        <>
          <EditButton
            routeParams={{
              companyId: companyId.toString(),
              projectId: projectId.toString(),
              completionSnapshotId: completionSnapshotId.toString(),
            }}
          />
        </>
      )}
      {completionSnapshotStatus === "invoiced" && "TO DO"}
      {completionSnapshotStatus === "cancelled" && "TO DO"}
    </div>
  );
};

export { CompletionSnapshotActions };
