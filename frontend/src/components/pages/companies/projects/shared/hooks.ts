import { Api } from "@/lib/openapi-fetch-query-client";
import { computeProjectVersionTotalAmount } from "../../project-versions/shared/utils";

const useProjectTotalAmount = ({
  companyId,
  projectId,
}: {
  companyId: number;
  projectId: number;
}) => {
  const { data: projectData } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/projects/{id}",
    {
      params: {
        path: { company_id: companyId, id: projectId },
      },
    },
    {
      select: (data) => data.result,
    }
  );

  if (projectData == undefined) {
    return {
      projectTotalAmount: undefined,
    };
  }

  return {
    projectTotalAmount: computeProjectVersionTotalAmount({
      items: projectData.last_version.items,
    }),
  };
};

const useProjectPreviouslyInvoicedTotalAmount = ({
  projectId,
}: {
  projectId: number;
}) => {
  const { data: invoicedAmounts } = Api.useQuery(
    "get",
    "/api/v1/organization/projects/{id}/invoiced_items",
    {
      params: {
        path: { id: projectId },
      },
    },
    {
      select: (data) => data.results,
    }
  );

  if (invoicedAmounts == undefined) {
    return {
      projectPreviouslyInvoicedTotalAmount: undefined,
    };
  }

  return {
    projectPreviouslyInvoicedTotalAmount: invoicedAmounts.reduce(
      (prev, current) => prev + Number(current.invoiced_amount),
      0
    ),
  };
};

export { useProjectTotalAmount, useProjectPreviouslyInvoicedTotalAmount };
