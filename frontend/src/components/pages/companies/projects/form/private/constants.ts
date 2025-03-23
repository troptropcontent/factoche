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

export { DEFAULT_TAX_RATE, CSV_FIELDS };
