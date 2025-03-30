import { z } from "zod";

const companyInfoSchema = z.object({
  name: z.string().min(1, "Company name is required"),
  registration_number: z.string(),
  email: z.string().email("Invalid email address"),
  phone: z.string(),
  address_city: z.string(),
  address_street: z.string(),
  address_zipcode: z.string(),
  legal_form: z.enum(["sasu", "sas", "eurl", "sa", "auto_entrepreneur"]),
  rcs_city: z.string(),
  rcs_number: z.string(),
  vat_number: z.string(),
  capital_amount: z.string(),
});

const billingConfigSchema = z.object({
  payment_term_days: z.coerce.number().int().min(0),
  payment_term_accepted_methods: z.array(z.enum(["transfer", "card", "cash"])),
  default_vat_rate: z.coerce.number().min(0),
  general_terms_and_conditions: z.string(),
});

const settingsFormSchema = companyInfoSchema.and(
  z.object({ configs: billingConfigSchema })
);

export { settingsFormSchema };
