import { z } from "zod";
import { ProformaExtended } from "../shared/types";
import { proformaFormSchema } from "./proforma-form-schema";
import { OrderExtended } from "../../orders/shared/types";
import { DeepPartial } from "react-hook-form";

const buildInitialValuesFromProforma = (
  proforma: ProformaExtended
): z.infer<typeof proformaFormSchema> => ({
  invoice_amounts: proforma.lines.map((line) => ({
    invoice_amount: Number(line.excl_tax_amount),
    original_item_uuid: line.holder_id,
  })),
});

const buildInitialValuesFromOrder = (
  order: OrderExtended
): z.infer<typeof proformaFormSchema> => ({
  invoice_amounts: order.last_version.items.map((item) => ({
    invoice_amount: 0,
    original_item_uuid: item.original_item_uuid,
  })),
});

const computeOrderTotalAmount = (order: OrderExtended) =>
  order.last_version.items.reduce((prev, current) => {
    return prev + current.quantity * Number(current.unit_price_amount);
  }, 0);

const computePreviouslyInvoicedAmount = (
  amounts: {
    original_item_uuid: string;
    invoiced_amount: string;
  }[]
) =>
  amounts.reduce((prev, current) => {
    return prev + Number(current.invoiced_amount);
  }, 0);

const computeProformaAmount = (
  formValues: DeepPartial<z.infer<typeof proformaFormSchema>>
) =>
  formValues?.invoice_amounts?.reduce((prev, invoiceAmount) => {
    return prev + Number(invoiceAmount?.invoice_amount || 0);
  }, 0) || 0;

export {
  buildInitialValuesFromProforma,
  buildInitialValuesFromOrder,
  computeOrderTotalAmount,
  computePreviouslyInvoicedAmount,
  computeProformaAmount,
};
