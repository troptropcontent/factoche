import { Api } from "@/lib/openapi-fetch-query-client";

const useInvoiceContentData = ({
  invoiceId,
  projectId,
  companyId,
}: {
  invoiceId: number;
  projectId: number;
  companyId: number;
}) => {
  const { data: invoiceData } = Api.useQuery(
    "get",
    "/api/v1/organization/projects/{project_id}/invoices/{id}",
    {
      params: {
        path: { project_id: projectId, id: invoiceId },
      },
    },
    { select: ({ result }) => result }
  );

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

  const { data: previouslyInvoicedAmounts } = Api.useQuery(
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

  const isDataLoaded =
    invoiceData != undefined &&
    projectData != undefined &&
    previouslyInvoicedAmounts != undefined;

  if (!isDataLoaded) {
    return { invoiceContentData: undefined };
  }

  const findPreviopuslyInvoicedAmount = (originalItemUuid: string) => {
    const amount = previouslyInvoicedAmounts.find(
      (previouslyInvoicedAmount) =>
        previouslyInvoicedAmount.original_item_uuid === originalItemUuid
    );

    return amount ? Number(amount.invoiced_amount) : 0;
  };

  const findInvoicedAmount = (originalItemUuid: string) => {
    const line = invoiceData.lines.find(
      (line) => line.holder_id === originalItemUuid
    );

    return line ? Number(line.excl_tax_amount) : 0;
  };

  return {
    invoiceContentData: {
      items: projectData.last_version.items.map((item) => ({
        name: item.name,
        quantity: item.quantity,
        unit: item.unit,
        unitPriceAmount: item.unit_price_cents / 100,
        totalAmount: (item.quantity * item.unit_price_cents) / 100,
        previouslyInvoicedAmount: findPreviopuslyInvoicedAmount(
          item.original_item_uuid
        ),
        invoiceAmount: findInvoicedAmount(item.original_item_uuid),
        groupId: item.item_group_id,
      })),
      groups: projectData.last_version.item_groups.map((group) => ({
        name: group.name,
        id: group.id,
      })),
    },
  };
};

export { useInvoiceContentData };
