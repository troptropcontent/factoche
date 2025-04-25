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

const TransactionDetailsGroupedLine = ({
  item: {
    name,
    previously_billed_amount,
    quantity,
    unit_price_amount,
    unit,
    original_item_uuid,
  },
  lines,
}: {
  item: FinancialTransactionExtended["context"]["project_version_items"][number];
  lines: FinancialTransactionExtended["lines"];
}) => {
  const { t } = useTranslation();

  const line = lines.find(({ holder_id }) => original_item_uuid === holder_id);
  const parsedUnitPriceAmount = Number(unit_price_amount);
  const parsedQuantity = Number(quantity);
  const parsedTotal = parsedUnitPriceAmount * parsedQuantity;
  const parsedPreviouslyInvoicedAmount = Number(previously_billed_amount);
  const parsedInvoiceAmount = line?.excl_tax_amount
    ? Number(line.excl_tax_amount)
    : 0;

  return (
    <TableRow>
      <TableCell className="font-medium">
        <div>
          <p className="truncate max-w-[200px]" title={name}>
            {name}
          </p>
          <p className="truncate text-xs text-muted-foreground">
            {quantity} {unit}
            {" @ "}
            {t("common.number_in_currency", {
              amount: parsedUnitPriceAmount,
            })}
          </p>
        </div>
      </TableCell>
      <TableCell className="align-top text-center">
        {t("common.number_in_currency", {
          amount: parsedTotal,
        })}
      </TableCell>
      <TableCell className="text-center">
        <div>
          <p>
            {t("common.number_in_currency", {
              amount: parsedPreviouslyInvoicedAmount,
            })}
          </p>
          <p className="text-xs text-muted-foreground">
            {t("common.number_in_percentage", {
              amount: (parsedPreviouslyInvoicedAmount / parsedTotal) * 100,
            })}
          </p>
        </div>
      </TableCell>
      <TableCell className="text-center">
        <div>
          <p>
            {t("common.number_in_currency", {
              amount: parsedPreviouslyInvoicedAmount + parsedInvoiceAmount,
            })}
          </p>
          <p className="text-xs text-muted-foreground">
            {t("common.number_in_percentage", {
              amount:
                ((parsedPreviouslyInvoicedAmount + parsedInvoiceAmount) /
                  parsedTotal) *
                100,
            })}
          </p>
        </div>
      </TableCell>
      <TableCell className="text-center">
        {t("common.number_in_currency", {
          amount: parsedInvoiceAmount,
        })}
      </TableCell>
    </TableRow>
  );
};

const TransactionDetailsGroupedLines = ({
  group,
  items,
  transactionLines,
}: {
  group: FinancialTransactionExtended["context"]["project_version_item_groups"][number];
  items: FinancialTransactionExtended["context"]["project_version_items"];
  transactionLines: FinancialTransactionExtended["lines"];
}) => {
  const { t } = useTranslation();

  return (
    <Card className="mb-4 last:mb-0">
      <CardHeader>
        <CardTitle>{group.name}</CardTitle>
        {group.description && (
          <p className="text-sm text-gray-600">{group.description}</p>
        )}
      </CardHeader>
      <CardContent>
        <div className="overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-[30%] align-top">
                  {t(
                    "pages.companies.projects.invoices.completion_snapshot.show.content.withGroups.columns.name"
                  )}
                </TableHead>
                <TableHead className="w-[15%] align-top text-center">
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
              {items.map((item, index) => (
                <TransactionDetailsGroupedLine
                  key={index}
                  item={item}
                  lines={transactionLines}
                />
              ))}
            </TableBody>
          </Table>
        </div>
      </CardContent>
    </Card>
  );
};

export { TransactionDetailsGroupedLines };
