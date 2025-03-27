import { Api } from "@/lib/openapi-fetch-query-client";
import {
  useProjectPreviouslyInvoicedTotalAmount,
  useProjectTotalAmount,
} from "../../projects/shared/hooks";
import { useInvoiceTotalAmount } from "../shared/hooks";

const useInvoiceContentData = ({
  invoiceId,
  orderId,
}: {
  invoiceId: number;
  orderId: number;
}) => {
  const { data: invoiceData } = Api.useQuery(
    "get",
    "/api/v1/organization/orders/{order_id}/invoices/{id}",
    {
      params: {
        path: { order_id: orderId, id: invoiceId },
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

  // For invoices that are not draft we want to display the data stored in the invoice context not the live data
  if (invoiceData.status != "draft") {
    return {
      invoiceContentData: {
        items: invoiceData.context.project_version_items.map((item) => ({
          name: item.name,
          quantity: item.quantity,
          unit: item.unit,
          unitPriceAmount: Number(item.unit_price_amount),
          totalAmount: item.quantity * Number(item.unit_price_amount),
          previouslyInvoicedAmount: Number(item.previously_billed_amount),
          invoiceAmount: findInvoicedAmount(item.original_item_uuid),
          groupId: item.group_id,
        })),
        groups: invoiceData.context.project_version_item_groups.map(
          (group) => ({
            name: group.name,
            id: group.id,
          })
        ),
      },
    };
  }

  const findPreviopuslyInvoicedAmount = (originalItemUuid: string) => {
    const amount = previouslyInvoicedAmounts.find(
      (previouslyInvoicedAmount) =>
        previouslyInvoicedAmount.original_item_uuid === originalItemUuid
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

const useInvoicingSummaryCardData = ({
  invoiceId,
  orderId,
}: {
  invoiceId: number;
  orderId: number;
}) => {
  const { projectTotalAmount } = useProjectTotalAmount({
    orderId,
  });

  const { data: invoiceData } = Api.useQuery(
    "get",
    "/api/v1/organization/orders/{order_id}/invoices/{id}",
    {
      params: {
        path: { order_id: orderId, id: invoiceId },
      },
    },
    { select: ({ result }) => result }
  );

  const { projectPreviouslyInvoicedTotalAmount } =
    useProjectPreviouslyInvoicedTotalAmount({ orderId });

  const { invoiceTotalAmount } = useInvoiceTotalAmount({
    orderId,
    invoiceId,
  });

  if (
    projectTotalAmount == undefined ||
    invoiceData == undefined ||
    projectPreviouslyInvoicedTotalAmount == undefined ||
    invoiceTotalAmount == undefined
  ) {
    return {
      invoicingSummaryCardData: undefined,
    };
  }

  const previouslyInvoicedAmount =
    invoiceData.status == "draft"
      ? projectPreviouslyInvoicedTotalAmount
      : Number(invoiceData.context.project_total_previously_billed_amount);

  return {
    invoicingSummaryCardData: {
      projectTotalAmount: projectTotalAmount,
      previouslyInvoicedAmount,
      newSnapshotAmount: previouslyInvoicedAmount + invoiceTotalAmount,
      invoiceTotalAmount,
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

export {
  useInvoiceContentData,
  useInvoicingSummaryCardData,
  useProformaQuery,
  useInvoicesQuery,
};
