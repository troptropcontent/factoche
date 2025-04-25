import { Api } from "@/lib/openapi-fetch-query-client";

import { proformaFormSchema } from "./proforma-form-schema";
import { z } from "zod";
import { useFormContext } from "react-hook-form";

const useProformaFormItemGroupItemRow = ({
  item,
  orderId,
}: {
  item: {
    id: number;
    name: string;
    description?: string | null;
    quantity: number;
    unit_price_amount: string;
    unit: string;
    original_item_uuid: string;
  };
  orderId: number;
}) => {
  const rowTotal = item.quantity * Number(item.unit_price_amount);
  const { data: previouslyInvoicedAmount } = Api.useQuery(
    "get",
    "/api/v1/organization/orders/{id}/invoiced_items",
    {
      params: { path: { id: orderId } },
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
  } = useFormContext<z.infer<typeof proformaFormSchema>>();

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

export { useProformaFormItemGroupItemRow };
