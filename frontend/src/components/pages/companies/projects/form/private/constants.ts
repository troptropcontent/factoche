import { z } from "zod";
import { formSchema } from "../project-form.schema";

const DEFAULT_TAX_RATE = 20 as const;

const CSV_FIELDS = {
  group: {
    type: "string",
  },
  name: {
    type: "string",
  },
  quantity: {
    type: "number",
  },
  unit: {
    type: "string",
  },
  unit_price_amount: {
    type: "number",
  },
  tax_rate: {
    type: "percentage",
  },
} as const;

const PROJECT_TYPES = ["quote", "draftOrder", "order"] as const;

const PROJECT_FORM_INITIAL_VALUES = {
  name: "",
  description: "",
  client_id: 0,
  bank_detail_id: 0,
  po_number: "",
  address_street: "",
  address_city: "",
  address_zipcode: "",
  retention_guarantee_rate: 0,
  items: [],
  groups: [],
  discounts: [],
} as const satisfies z.infer<typeof formSchema>;

export {
  DEFAULT_TAX_RATE,
  CSV_FIELDS,
  PROJECT_FORM_INITIAL_VALUES,
  PROJECT_TYPES,
};
