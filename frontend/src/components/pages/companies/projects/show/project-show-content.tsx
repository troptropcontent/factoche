import { useState } from "react";
import { ClientInfo } from "./client-info";
import { Api } from "@/lib/openapi-fetch-query-client";
import { ProjectComposition } from "./project-composition";
import { useQueryClient } from "@tanstack/react-query";
import { VersionSelect } from "./version-select";

const ProjectShowContent = ({
  companyId,
  projectId,
  client,
  initialVersionId,
}: {
  companyId: number;
  projectId: number;
  initialVersionId: number;
  client: { name: string; phone: string; email: string };
}) => {
  const [currentVersionId, setCurrentVersionId] = useState(initialVersionId);
  const { data: { results: versions } = { results: [] } } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/projects/{project_id}/versions",
    {
      params: {
        path: { company_id: companyId, project_id: projectId },
      },
    }
  );
  const queryClient = useQueryClient();
  const handleVersionChange = async (value: string) => {
    // Preload the query needed in the component to avoid blink loading
    await queryClient.ensureQueryData(
      Api.queryOptions(
        "get",
        "/api/v1/organization/companies/{company_id}/projects/{project_id}/versions/{id}",
        {
          params: {
            path: {
              company_id: companyId,
              project_id: projectId,
              id: Number.parseInt(value, 10),
            },
          },
        }
      )
    );
    setCurrentVersionId(Number.parseInt(value, 10));
  };

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
      <div className="md:col-span-1">
        <ClientInfo client={client} />
        <VersionSelect
          onValueChange={handleVersionChange}
          versionId={currentVersionId.toString()}
          versions={versions}
        />
      </div>
      <div className="md:col-span-2">
        <ProjectComposition
          companyId={companyId}
          projectId={projectId}
          versionId={currentVersionId}
        />
      </div>
    </div>
  );
};

export { ProjectShowContent };
