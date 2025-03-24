import { Api } from "@/lib/openapi-fetch-query-client";
import { computeProjectVersionTotalAmount } from "../../project-versions/shared/utils";

const useProjectTotalAmount = ({ orderId }: { orderId: number }) => {
  const { data: projectData } = Api.useQuery(
    "get",
    "/api/v1/organization/orders/{id}",
    {
      params: {
        path: { id: orderId },
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
      items: projectData.last_version.items.map((item) => ({
        ...item,
        unit_price_amount: Number(item.unit_price_amount),
      })),
    }),
  };
};

const useProjectPreviouslyInvoicedTotalAmount = ({
  orderId,
}: {
  orderId: number;
}) => {
  const { data: invoicedAmounts } = Api.useQuery(
    "get",
    "/api/v1/organization/orders/{id}/invoiced_items",
    {
      params: {
        path: { id: orderId },
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
