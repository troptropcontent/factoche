import { z } from "zod";

const completionSnapshotInvoiceFormSchema = z.object({
  invoiced_amounts: z.array(
    z.object({ original_item_uuid: z.string(), invoice_amount: z.number() })
  ),
});

export { completionSnapshotInvoiceFormSchema };
