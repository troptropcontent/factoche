import { Api } from "@/lib/openapi-fetch-query-client";
import { ClientSummaryCard } from "../clients/shared/client-summary-card";
import { ProjectSummaryCard } from "../projects/shared/project-summary-card";
import { Card, CardContent } from "@/components/ui/card";
import { CompletionSnapshotActions } from "./private/completion-snapshot-actions";
import { CompletionSnapshotSummary } from "./completion-snapshot-summary";
import { CompletionSnapshotDetails } from "./completion-snapshot-details";

const CompletionSnapshotShow = ({
  routeParams: { companyId, projectId, completionSnapshotId },
}: {
  routeParams: {
    companyId: number;
    projectId: number;
    completionSnapshotId: number;
  };
}) => {
  const { data: completionSnapshotData } = Api.useQuery(
    "get",
    "/api/v1/organization/completion_snapshots/{id}",
    {
      params: {
        path: { id: completionSnapshotId },
      },
    }
  );

  const isCompletionSnapshotLoaded = completionSnapshotData != undefined;

  const { data: projectData } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/projects/{id}",
    { params: { path: { company_id: companyId, id: projectId } } }
  );

  const isProjectDataLoaded = projectData != undefined;

  if (!isCompletionSnapshotLoaded || !isProjectDataLoaded) {
    return null;
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
      <div className="md:col-span-1 space-y-6">
        <ProjectSummaryCard routeParams={{ companyId, projectId }} />
        <ClientSummaryCard clientId={projectData.result.client.id} />
        <CompletionSnapshotActions
          routeParams={{ companyId, projectId, completionSnapshotId }}
          completionSnapshotStatus={completionSnapshotData.result.status}
        />
      </div>
      <div className="md:col-span-2">
        <Card>
          <CardContent className="mt-6 space-y-6">
            <CompletionSnapshotSummary
              routeParams={{
                companyId,
                projectId,
                completionSnapshotId: completionSnapshotData.result.id,
                projectVersionId:
                  completionSnapshotData.result.project_version.id,
              }}
            />
            <CompletionSnapshotDetails
              completionSnapshotId={completionSnapshotId}
            />
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

export { CompletionSnapshotShow };
