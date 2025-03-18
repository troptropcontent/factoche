import { useFormContext, useWatch } from "react-hook-form";

import { invoiceFormSchema } from "./schemas";
import { z } from "zod";
import { Api } from "@/lib/openapi-fetch-query-client";

const useNewInvoiceTotalAmount = () => {
  const formValues = useWatch<z.infer<typeof invoiceFormSchema>>();

  return formValues.invoice_amounts?.reduce((prev, current) => {
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
    unit_price_amount: number;
    unit: string;
    original_item_uuid: string;
  };
  projectId: number;
}) => {
  const rowTotal = item.quantity * item.unit_price_amount;
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
  } = useFormContext<z.infer<typeof invoiceFormSchema>>();

  if (defaultValues?.invoice_amounts == undefined) {
    throw new Error(
      "This hook must be used within a form context with properly initialized default values"
    );
  }

  const itemInputIndex = defaultValues.invoice_amounts.findIndex(
    (invoicedAmount) =>
      invoicedAmount?.original_item_uuid === item.original_item_uuid
  );

  if (itemInputIndex == undefined) {
    throw new Error(
      `Could not find index for item ${item.original_item_uuid} in form default values. This is likely an error.`
    );
  }

  const inputName = `invoice_amounts.${itemInputIndex}.invoice_amount` as const;

  const newInvoiceAmount = watch(inputName);

  if (previouslyInvoicedAmount == undefined) {
    return {
      rowTotal: undefined,
      currentCompletionAmount: undefined,
      currentCompletionPercentage: undefined,
      updateItemInputInvoiceAmount: undefined,
      previouslyInvoicedAmount: undefined,
      newInvoiceAmount: undefined,
      newInvoicePercentage: undefined,
      isLoading: true as const,
    };
  }

  const currentCompletionAmount = previouslyInvoicedAmount + newInvoiceAmount;

  const newInvoicePercentage = Math.round(
    (currentCompletionAmount / rowTotal) * 100
  );

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
    newInvoicePercentage,
    isLoading: false as const,
  };
};

export { useNewInvoiceTotalAmount, useCompletionSnapshotInvoiceItemRow };
