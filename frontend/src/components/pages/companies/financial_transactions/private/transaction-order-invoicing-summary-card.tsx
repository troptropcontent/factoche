import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

import { useTranslation } from "react-i18next";
import { FinancialTransactionExtended } from "../shared/types";

const TransactionOrderInvoicingSummaryCard = ({
  financialTransaction,
}: {
  financialTransaction: FinancialTransactionExtended;
}) => {
  const { t } = useTranslation();

  const financialTransactionAmount = Number(
    financialTransaction.total_excl_tax_amount
  );
  const orderTotalAmount = Number(
    financialTransaction.context.project_total_amount
  );
  const orderPreviouslyInvoicedAmount = Number(
    financialTransaction.context.project_total_previously_billed_amount
  );
  const orderNewSnapshotAmount =
    orderPreviouslyInvoicedAmount + financialTransactionAmount;

  return (
    <Card>
      <CardHeader>
        <CardTitle>
          {t("pages.companies.completion_snapshot.show.summary.new.title")}
        </CardTitle>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="w-[15%] align-top">
                {t(
                  "pages.companies.projects.invoices.completion_snapshot.show.content.withGroups.columns.total"
                )}
              </TableHead>
              <TableHead className="w-[15%] text-center">
                {t(
                  "pages.companies.projects.invoices.completion_snapshot.show.content.withGroups.columns.previously_invoiced"
                )}
                <br />
                (a)
              </TableHead>
              <TableHead className="w-[20%] text-center">
                {t(
                  "pages.companies.projects.invoices.completion_snapshot.show.content.withGroups.columns.new_snapshot"
                )}
                <br />
                (b)
              </TableHead>
              <TableHead className="w-[20%] text-center">
                {t(
                  "pages.companies.projects.invoices.completion_snapshot.show.content.withGroups.columns.new_invoice"
                )}
                <br />
                (b - a)
              </TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow>
              <TableCell className="align-top">
                {t("common.number_in_currency", {
                  amount: orderTotalAmount,
                })}
              </TableCell>
              <TableCell className="text-center">
                <div>
                  <p>
                    {t("common.number_in_currency", {
                      amount: orderPreviouslyInvoicedAmount,
                    })}
                  </p>
                  <p className="text-xs text-muted-foreground">
                    {t("common.number_in_percentage", {
                      amount:
                        (orderPreviouslyInvoicedAmount / orderTotalAmount) *
                        100,
                    })}
                  </p>
                </div>
              </TableCell>
              <TableCell className="text-center">
                <div>
                  <p>
                    {t("common.number_in_currency", {
                      amount: orderNewSnapshotAmount,
                    })}
                  </p>
                  <p className="text-xs text-muted-foreground">
                    {t("common.number_in_percentage", {
                      amount: (orderNewSnapshotAmount / orderTotalAmount) * 100,
                    })}
                  </p>
                </div>
              </TableCell>
              <TableCell className="text-center align-top">
                {t("common.number_in_currency", {
                  amount: financialTransactionAmount,
                })}
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
};

export { TransactionOrderInvoicingSummaryCard };
