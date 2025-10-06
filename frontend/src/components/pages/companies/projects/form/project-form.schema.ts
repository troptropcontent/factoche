import { z } from "zod";

const step1FormSchema = z.object({
  name: z.string().min(1),
  description: z.string().optional(),
  client_id: z.number().min(1),
  bank_detail_id: z.number().min(1),
  retention_guarantee_rate: z.number(),
  address_street: z.string(),
  address_city: z.string(),
  address_zipcode: z.string(),
  po_number: z.string(),
});

const step2FormSchema = z.object({
  items: z
    .object({
      original_item_uuid: z.string().optional(),
      group_uuid: z.string().optional(),
      uuid: z.string(),
      name: z.string().min(1),
      position: z.number().min(0),
      description: z.string().optional(),
      unit: z.string().min(1),
      quantity: z.number().min(1),
      unit_price_amount: z.number().min(0.01),
      tax_rate: z.number(),
    })
    .array()
    .min(1),
  groups: z
    .object({
      uuid: z.string(),
      name: z.string().min(1),
      position: z.number().min(0),
      description: z.string().optional(),
    })
    .array(),
});

const formSchema = step1FormSchema.and(step2FormSchema);

export { formSchema, step1FormSchema, step2FormSchema };
