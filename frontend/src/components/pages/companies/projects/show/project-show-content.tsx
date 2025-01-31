import { ClientInfo } from "./client-info";
import { ProjectVersionComposition } from "./project-version-composition";
import { CompletionSnapshotsSummery } from "./completion-snapshots-summary";
import { ProjectSummary } from "./project-summary";

const ProjectShowContent = ({
  companyId,
  projectId,
  client,
  initialVersionId,
}: {
  companyId: number;
  projectId: number;
  initialVersionId: number;
  lastVersionId: number;
  client: { name: string; phone: string; email: string };
}) => {
  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
      <div className="md:col-span-1">
        <ProjectSummary routeParams={{ companyId, projectId }} />
        <ClientInfo client={client} />
        <CompletionSnapshotsSummery
          companyId={companyId}
          projectId={projectId}
        />
      </div>
      <div className="md:col-span-2">
        <ProjectVersionComposition
          routeParams={{ companyId, projectId }}
          initialVersionId={initialVersionId}
        />
      </div>
    </div>
  );
};

export { ProjectShowContent };
