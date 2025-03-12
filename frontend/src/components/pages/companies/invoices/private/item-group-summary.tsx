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
import { useInvoiceContentData } from "./hooks";

const ItemGroupSummary = ({
  name,
  description,
  items,
}: {
  name: string;
  description?: string | null;
  items: NonNullable<
    ReturnType<typeof useInvoiceContentData>["invoiceContentData"]
  >["items"];
}) => {
  const { t } = useTranslation();
  console.log({ items });
  return (
    <Card className="mb-4 last:mb-0">
      <CardHeader>
        <CardTitle>{name}</CardTitle>
        <p className="text-sm text-gray-600">{description}</p>
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
                <TableRow key={index}>
                  <TableCell className="font-medium">
                    <div>
                      <p className="truncate max-w-[200px]" title={item.name}>
                        {item.name}
                      </p>
                      <p className="truncate text-xs text-muted-foreground">
                        {item.quantity} {item.unit}
                        {" @ "}
                        {t("common.number_in_currency", {
                          amount: item.unitPriceAmount,
                        })}
                      </p>
                    </div>
                  </TableCell>
                  <TableCell className="align-top text-center">
                    {t("common.number_in_currency", {
                      amount: item.totalAmount,
                    })}
                  </TableCell>
                  <TableCell className="text-center">
                    <div>
                      <p>
                        {t("common.number_in_currency", {
                          amount: item.previouslyInvoicedAmount,
                        })}
                      </p>
                      <p className="text-xs text-muted-foreground">
                        {t("common.number_in_percentage", {
                          amount:
                            item.previouslyInvoicedAmount / item.totalAmount,
                        })}
                      </p>
                    </div>
                  </TableCell>
                  <TableCell className="text-center">
                    <div>
                      <p>
                        {t("common.number_in_currency", {
                          amount:
                            item.previouslyInvoicedAmount + item.invoiceAmount,
                        })}
                      </p>
                      <p className="text-xs text-muted-foreground">
                        {t("common.number_in_percentage", {
                          amount:
                            ((item.previouslyInvoicedAmount +
                              item.invoiceAmount) /
                              item.totalAmount) *
                            100,
                        })}
                      </p>
                    </div>
                  </TableCell>
                  <TableCell className="text-center">
                    {t("common.number_in_currency", {
                      amount: item.invoiceAmount,
                    })}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      </CardContent>
    </Card>
  );
};

export { ItemGroupSummary };
