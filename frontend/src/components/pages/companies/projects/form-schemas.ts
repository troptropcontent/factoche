import { z } from "zod";

const Step1FormDataSchema = z.object({
  name: z.string().min(1),
  description: z.string(),
  client_id: z.number().min(1),
  retention_guarantee_rate: z.number().min(0),
});

const baseItemSchema = z.object({
  name: z.string().min(1),
  position: z.number().min(0),
  description: z.string(),
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

const Step2FormDataSchema = z.object({
  items: z.union([itemSchema, itemGroupSchema]).array().min(1),
});

type Step2FormType = z.infer<typeof Step2FormDataSchema>;

export { Step1FormDataSchema, Step2FormDataSchema };

export type { Step2FormType };
