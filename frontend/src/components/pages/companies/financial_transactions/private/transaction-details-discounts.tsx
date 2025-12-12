import {
  Card,
  CardContent,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
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

const TransactionDetailsDiscountsRow = ({
  discount: { excl_tax_amount, holder_id: discountHolderId },
  discountsData,
}: {
  discount: FinancialTransactionExtended["lines"][number];
  discountsData: FinancialTransactionExtended["context"]["project_version_discounts"];
}) => {
  const { t } = useTranslation();
  const discountData = discountsData.find(
    ({ original_discount_uuid }) => original_discount_uuid === discountHolderId
  );

  if (!discountData) {
    throw new Error(
      `Discount data not found for holder_id: ${discountHolderId}. This indicates a data consistency issue between transaction lines and project version discounts.`
    );
  }

  return (
    <TableRow>
      <TableCell className="font-medium">
        <div>
          <p className="truncate max-w-[200px]" title={discountData.name!}>
            {discountData.name!}
          </p>
          <p className="truncate text-xs text-muted-foreground">
            {t(
              `pages.companies.proformas.form.discounts.hint.${discountData.kind}`,
              {
                value: t("common.number_in_percentage", {
                  amount: Number(discountData.value) * 100,
                }),
                amount: t("common.number_in_currency", {
                  amount: discountData.amount,
                }),
              }
            )}
          </p>
        </div>
      </TableCell>
      <TableCell className="text-center">
        {t("common.number_in_currency", {
          amount: excl_tax_amount,
        })}
      </TableCell>
    </TableRow>
  );
};

const TransactionDetailsDiscounts = ({
  financialTransaction,
}: {
  financialTransaction: FinancialTransactionExtended;
}) => {
  const { t } = useTranslation();

  const discounts = financialTransaction.lines.filter(
    ({ kind }) => kind === "discount"
  );

  return (
    <Card>
      <CardHeader>
        <CardTitle>
          {t("pages.companies.completion_snapshot.discounts.card_header")}
        </CardTitle>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>
                {t("pages.companies.completion_snapshot.discounts.name")}
              </TableHead>

              <TableHead className="w-[20%] text-center">
                {t("pages.companies.completion_snapshot.discounts.amount")}
              </TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {discounts.map((discount) => (
              <TransactionDetailsDiscountsRow
                discount={discount}
                discountsData={
                  financialTransaction.context.project_version_discounts || []
                }
              />
            ))}
          </TableBody>
        </Table>
      </CardContent>
      <CardFooter>
        <p className="text-xs italic text-muted-foreground ml-auto">
          {t("pages.companies.completion_snapshot.discounts.card_footer")}
        </p>
      </CardFooter>
    </Card>
  );
};

export { TransactionDetailsDiscounts };
