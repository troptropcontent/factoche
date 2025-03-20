import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
  CardFooter,
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
import { computeTotal } from "./utils";

const ItemGroupSummary = ({
  name,
  description,
  items,
}: {
  name: string;
  description?: string | null;
  items: Array<{
    uuid: string;
    position: number;
    name: string;
    description?: string | null;
    quantity: number;
    unit_price_amount: number;
    tax_rate: number;
    unit: string;
  }>;
}) => {
  const groupTotal = computeTotal(items);
  const { t } = useTranslation();

  return (
    <Card>
      <CardHeader>
        <CardTitle>{name}</CardTitle>
        <p className="text-sm text-gray-600">{description}</p>
      </CardHeader>
      <CardContent>
        <div className="overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-[30%]">
                  {t(
                    "pages.companies.projects.form.composition_step.item_name_input_label"
                  )}
                </TableHead>
                <TableHead className="w-[15%]">
                  {t(
                    "pages.companies.projects.form.composition_step.item_quantity_input_label"
                  )}
                </TableHead>
                <TableHead className="w-[15%]">
                  {t(
                    "pages.companies.projects.form.composition_step.item_unit_input_label"
                  )}
                </TableHead>
                <TableHead className="w-[20%]">
                  {t(
                    "pages.companies.projects.form.composition_step.item_unit_price_input_label"
                  )}
                </TableHead>
                <TableHead className="w-[20%]">
                  {t(
                    "pages.companies.projects.form.composition_step.item_total_label"
                  )}
                </TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {items.map((item, index) => (
                <TableRow key={index}>
                  <TableCell className="font-medium">
                    <div className="truncate max-w-[200px]" title={item.name}>
                      {item.name}
                    </div>
                    {item.description && (
                      <div
                        className="text-xs text-gray-500 truncate max-w-[200px]"
                        title={item.description}
                      >
                        {item.description}
                      </div>
                    )}
                  </TableCell>
                  <TableCell>{item.quantity}</TableCell>
                  <TableCell>{item.unit}</TableCell>
                  <TableCell>
                    {t("common.number_in_currency", {
                      amount: item.unit_price_amount,
                    })}
                  </TableCell>
                  <TableCell>
                    {t("common.number_in_currency", {
                      amount: item.quantity * item.unit_price_amount,
                    })}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      </CardContent>
      <CardFooter className="justify-end">
        <div className="text-right font-semibold">
          {t(
            "pages.companies.projects.form.confirmation_step.group_total_label",
            {
              total: t("common.number_in_currency", {
                amount: groupTotal,
              }),
            }
          )}
        </div>
      </CardFooter>
    </Card>
  );
};

export { ItemGroupSummary };
