import { useFormContext, useWatch } from "react-hook-form";

import { completionSnapshotInvoiceFormSchema } from "./schemas";
import { z } from "zod";
import { Api } from "@/lib/openapi-fetch-query-client";

const useNewInvoiceTotalAmount = () => {
  const formValues =
    useWatch<z.infer<typeof completionSnapshotInvoiceFormSchema>>();

  return formValues.invoiced_amounts?.reduce((prev, current) => {
    const invoiceAmount = current.invoice_amount || 0;
    return prev + invoiceAmount;
  }, 0);
};

const useCompletionSnapshotInvoiceItemRow = ({
  item,
  projectId,
}: {
  item: {
    id: number;
    name: string;
    description?: string | null;
    quantity: number;
    unit_price_cents: number;
    unit: string;
    original_item_uuid: string;
  };
  projectId: number;
}) => {
  const rowTotal = (item.quantity * item.unit_price_cents) / 100;
  const { data: previouslyInvoicedAmount } = Api.useQuery(
    "get",
    "/api/v1/organization/projects/{id}/invoiced_items",
    {
      params: { path: { id: projectId } },
    },
    {
      select: ({ results }) => {
        return Number(
          results.find(
            ({ original_item_uuid }) =>
              original_item_uuid === item.original_item_uuid
          )?.invoiced_amount || "0.0"
        );
      },
    }
  );

  const {
    watch,
    formState: { defaultValues },
    setValue,
  } = useFormContext<z.infer<typeof completionSnapshotInvoiceFormSchema>>();

  if (defaultValues?.invoiced_amounts == undefined) {
    throw new Error(
      "This hook must be used within a form context with properly initialized default values"
    );
  }

  const itemInputIndex = defaultValues.invoiced_amounts.findIndex(
    (invoicedAmount) =>
      invoicedAmount?.original_item_uuid === item.original_item_uuid
  );

  if (itemInputIndex == undefined) {
    throw new Error(
      `Could not find index for item ${item.original_item_uuid} in form default values. This is likely an error.`
    );
  }

  const inputName =
    `invoiced_amounts.${itemInputIndex}.invoice_amount` as const;

  const newInvoiceAmount = watch(inputName);

  if (previouslyInvoicedAmount == undefined) {
    return {
      rowTotal: undefined,
      currentCompletionAmount: undefined,
      currentCompletionPercentage: undefined,
      updateItemInputInvoiceAmount: undefined,
      previouslyInvoicedAmount: undefined,
      newInvoiceAmount: undefined,
      isLoading: true as const,
    };
  }

  const currentCompletionAmount = previouslyInvoicedAmount + newInvoiceAmount;

  const currentCompletionPercentage = Math.round(
    (previouslyInvoicedAmount / rowTotal) * 100
  );

  const updateItemInputInvoiceAmount = (
    newCompletionPercentageString: string
  ) => {
    const newCompletionPercentageNumber = Number(newCompletionPercentageString);
    const newCompletionAmount =
      (rowTotal * newCompletionPercentageNumber) / 100;

    setValue(inputName, newCompletionAmount - previouslyInvoicedAmount);
  };

  return {
    rowTotal,
    currentCompletionAmount,
    currentCompletionPercentage,
    updateItemInputInvoiceAmount,
    previouslyInvoicedAmount,
    newInvoiceAmount,
    isLoading: false as const,
  };
};

export { useNewInvoiceTotalAmount, useCompletionSnapshotInvoiceItemRow };
