import { Api } from "@/lib/openapi-fetch-query-client";

const useInvoiceContentData = ({
  invoiceId,
  orderId,
}: {
  invoiceId: number;
  orderId: number;
}) => {
  const { data: invoiceData } = Api.useQuery(
    "get",
    "/api/v1/organization/invoices/{id}",
    {
      params: {
        path: { id: invoiceId },
      },
    },
    { select: ({ result }) => result }
  );

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

  const { data: previouslyInvoicedAmounts } = Api.useQuery(
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

  const isDataLoaded =
    invoiceData != undefined &&
    projectData != undefined &&
    previouslyInvoicedAmounts != undefined;

  if (!isDataLoaded) {
    return { invoiceContentData: undefined };
  }

  const findInvoicedAmount = (originalItemUuid: string) => {
    const line = invoiceData.lines.find(
      (line) => line.holder_id === originalItemUuid
    );

    return line ? Number(line.excl_tax_amount) : 0;
  };

  const findPreviopuslyInvoicedAmount = (originalItemUuid: string) => {
    const amount = previouslyInvoicedAmounts.find(
      (previouslyInvoicedAmount) =>
        previouslyInvoicedAmount.uuid === originalItemUuid
    );

    return amount ? Number(amount.invoiced_amount) : 0;
  };

  return {
    invoiceContentData: {
      items: projectData.last_version.items.map((item) => ({
        name: item.name,
        quantity: item.quantity,
        unit: item.unit,
        unitPriceAmount: Number(item.unit_price_amount),
        totalAmount: item.quantity * Number(item.unit_price_amount),
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

const useProformaQuery = (companyId: string) =>
  Api.useQuery("get", "/api/v1/organization/companies/{company_id}/invoices", {
    params: {
      path: { company_id: Number(companyId) },
      query: { status: ["draft", "voided"] },
    },
  });

const useInvoicesQuery = (companyId: string) =>
  Api.useQuery("get", "/api/v1/organization/companies/{company_id}/invoices", {
    params: {
      path: { company_id: Number(companyId) },
      query: { status: ["posted", "cancelled"] },
    },
  });

const useCreditNotesQuery = (companyId: string) =>
  Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/credit_notes",
    {
      params: {
        path: { company_id: Number(companyId) },
      },
    },
    { select: ({ results }) => results }
  );

export {
  useInvoiceContentData,
  useProformaQuery,
  useInvoicesQuery,
  useCreditNotesQuery,
};
