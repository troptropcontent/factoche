import { Api } from "@/lib/openapi-fetch-query-client";
import { computeProjectVersionTotalCents } from "./utils";

const useProjectVersionTotalCents = ({
  companyId,
  projectId,
  projectVersionId,
}: {
  companyId: number;
  projectId: number;
  projectVersionId: number;
}) => {
  const { data } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/projects/{project_id}/versions/{id}",
    {
      params: {
        path: {
          company_id: companyId,
          project_id: projectId,
          id: projectVersionId,
        },
      },
    }
  );

  const projectVersion = data?.result;

  if (projectVersion == undefined) {
    return {
      projectVersionTotalCents: undefined,
      isLoading: true as const,
    };
  }

  return {
    projectVersionTotalCents: computeProjectVersionTotalCents(projectVersion),
    isLoading: false as const,
  };
};

export { useProjectVersionTotalCents };
