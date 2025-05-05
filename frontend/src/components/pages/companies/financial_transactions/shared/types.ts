import { InvoiceExtended } from "@/components/pages/companies/invoices/shared/types";
import { ProformaExtended } from "@/components/pages/companies/proformas/shared/types";

type FinancialTransactionExtended = ProformaExtended | InvoiceExtended;

export type { FinancialTransactionExtended };
