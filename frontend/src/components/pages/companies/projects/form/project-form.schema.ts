import { z } from "zod";

const step1FormSchema = z.object({
  name: z.string().min(1),
  description: z.string().optional(),
  client_id: z.number().min(1),
  retention_guarantee_rate: z.number(),
});

const baseItemSchema = z.object({
  name: z.string().min(1),
  position: z.number().min(0),
  description: z.string().optional(),
});

const itemSchema = baseItemSchema.and(
  z.object({
    type: z.literal("item"),
    unit: z.string().min(1),
    quantity: z.number().min(1),
    unit_price: z.number().min(0.01),
  })
);

const itemGroupSchema = baseItemSchema.and(
  z.object({
    type: z.literal("group"),
    items: itemSchema.array().min(1),
  })
);

const step2FormSchema = z.object({
  items: z.union([itemSchema, itemGroupSchema]).array().min(1),
});

const formSchema = step1FormSchema.and(step2FormSchema);

export { formSchema, step1FormSchema, step2FormSchema };
