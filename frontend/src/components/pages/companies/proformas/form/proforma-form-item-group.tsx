import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { useTranslation } from "react-i18next";
import { ProformaFormItemGroupItemRow } from "./proforma-form-item-group-item-row";

const ProformaFormItemGroup = ({
  group,
  items,
  orderId,
}: {
  group: { name: string; id: number; description?: string | null };
  items: {
    id: number;
    name: string;
    quantity: number;
    unit_price_amount: string;
    unit: string;
    original_item_uuid: string;
  }[];
  orderId: number;
}) => {
  const { t } = useTranslation();

  return (
    <Card>
      <CardHeader>
        <CardTitle>{group.name}</CardTitle>
        {group.description && <CardDescription>{group.name}</CardDescription>}
      </CardHeader>
      <CardContent>
        <Table className="table-fixed">
          <TableHeader>
            <TableRow>
              <TableHead className="w-[25%]">
                {t(
                  "pages.companies.projects.invoices.completion_snapshot.form.columns.designation"
                )}
              </TableHead>
              <TableHead className="w-[10%]">
                {t(
                  "pages.companies.projects.invoices.completion_snapshot.form.columns.total"
                )}
              </TableHead>
              <TableHead className="w-[25%] text-center" colSpan={2}>
                {t(
                  "pages.companies.projects.invoices.completion_snapshot.form.columns.previously_invoiced_amount"
                )}
              </TableHead>
              <TableHead className="w-[25%] text-center" colSpan={2}>
                {t(
                  "pages.companies.projects.invoices.completion_snapshot.form.columns.new_completion_percentage"
                )}
              </TableHead>
              <TableHead className="w-[15%] text-right">
                {t(
                  "pages.companies.projects.invoices.completion_snapshot.form.columns.new_invoice_amount"
                )}
              </TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {items.map((item) => (
              <ProformaFormItemGroupItemRow
                item={item}
                orderId={orderId}
                key={item.id}
              />
            ))}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
};

export { ProformaFormItemGroup };
