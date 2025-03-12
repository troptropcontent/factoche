import { Line } from "@/components/pages/companies/invoices/shared/types";

const computeInvoiceTotal = (lines: Line[]) => {
  return lines.reduce(
    (prev, current) => prev + Number(current.excl_tax_amount),
    0
  );
};

export { computeInvoiceTotal };
