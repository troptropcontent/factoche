import { Api } from "@/lib/openapi-fetch-query-client";
import { ClientSummaryCard } from "../clients/shared/client-summary-card";
import { ProjectSummaryCard } from "../projects/shared/project-summary-card";

const CompletionSnapshotShow = ({
  routeParams: { companyId, projectId },
}: {
  routeParams: { companyId: number; projectId: number };
}) => {
  const { data, isLoading } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/projects/{id}",
    {
      params: {
        path: { company_id: Number(companyId), id: Number(projectId) },
      },
    }
  );

  if (isLoading || data == undefined) {
    return null;
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
      <div className="md:col-span-1 space-y-6">
        <ProjectSummaryCard routeParams={{ companyId, projectId }} />
        <ClientSummaryCard clientId={data.result.client.id} />
      </div>
      <div className="md:col-span-2">content</div>
    </div>
  );
};

export { CompletionSnapshotShow };
