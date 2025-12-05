import {
  Card,
  CardContent,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { useTranslation } from "react-i18next";
import { useWatch } from "react-hook-form";
import { z } from "zod";
import { proformaFormSchema } from "./proforma-form-schema";
import { computeOrderTotalAmount, computeProformaAmount } from "./utils";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { OrderExtended } from "../../orders/shared/types";

const ProformaFormDiscountCard = ({ order }: { order: OrderExtended }) => {
  const { t } = useTranslation();
  const formValues = useWatch<z.infer<typeof proformaFormSchema>>();
  const proformaAmount = computeProformaAmount(formValues);
  const orderTotal = computeOrderTotalAmount(order);
  const proformaRatio = proformaAmount / orderTotal;

  return (
    <Card>
      <CardHeader>
        <CardTitle className="my-auto">
          {t("pages.companies.proformas.form.discounts.card_header")}
        </CardTitle>
      </CardHeader>
      <CardContent className="flex flex-col justify-between">
        <Table className="table-fixed">
          <TableHeader>
            <TableRow>
              <TableHead>
                {t(
                  "pages.companies.projects.invoices.completion_snapshot.form.columns.designation"
                )}
              </TableHead>

              <TableHead className="text-right">
                {t(
                  "pages.companies.projects.invoices.completion_snapshot.form.columns.new_invoice_amount"
                )}
              </TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {order.last_version.discounts.map((discount) => (
              <TableRow>
                <TableCell className="max-w-[200px] text-wrap">
                  <div>
                    <p title={discount.name} className="truncate">
                      {discount.name}
                    </p>
                    <p
                      title={discount.name}
                      className="truncate text-xs text-muted-foreground"
                    >
                      {t(
                        `pages.companies.proformas.form.discounts.hint.${discount.kind}`,
                        {
                          value: t("common.number_in_percentage", {
                            amount: Number(discount.value) * 100,
                          }),
                          amount: t("common.number_in_currency", {
                            amount: discount.amount,
                          }),
                        }
                      )}
                    </p>
                  </div>
                </TableCell>
                <TableCell className="text-right">
                  {t("common.number_in_currency", {
                    amount: -Number(discount.amount) * proformaRatio,
                  })}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </CardContent>
      <CardFooter>
        <p className="text-xs italic text-muted-foreground ml-auto">
          {t("pages.companies.proformas.form.discounts.card_footer")}
        </p>
      </CardFooter>
    </Card>
  );
};

export { ProformaFormDiscountCard };
