import { z } from "zod";
import { ProformaExtended } from "../shared/types";
import { proformaFormSchema } from "./proforma-form-schema";
import { OrderExtended } from "../../orders/shared/types";
import { DeepPartial } from "react-hook-form";

const buildInitialValuesFromProforma = (
  proforma: ProformaExtended,
  order: OrderExtended
): z.infer<typeof proformaFormSchema> => ({
  issue_date: new Date(proforma.issue_date)
    .toISOString()
    .split("T")[0] as string,
  invoice_amounts: order.last_version.items.map((item) => {
    const proformaAmount = proforma.lines.find(
      (line) => line.holder_id === item.original_item_uuid
    )?.excl_tax_amount;
    return {
      invoice_amount: proformaAmount ? Number(proformaAmount) : 0,
      original_item_uuid: item.original_item_uuid,
    };
  }),
});

const buildInitialValuesFromOrder = (
  order: OrderExtended
): z.infer<typeof proformaFormSchema> => ({
  issue_date: new Date().toISOString().split("T")[0] as string,
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
