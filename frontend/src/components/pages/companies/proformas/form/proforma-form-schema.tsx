import { z } from "zod";

const proformaFormSchema = z.object({
  invoice_amounts: z.array(
    z.object({ original_item_uuid: z.string(), invoice_amount: z.number() })
  ),
});

export { proformaFormSchema };
