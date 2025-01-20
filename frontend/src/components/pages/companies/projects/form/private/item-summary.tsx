import { TableHead, TableHeader } from "@/components/ui/table";
import { TableRow } from "@/components/ui/table";
import { TableBody } from "@/components/ui/table";
import { TableCell } from "@/components/ui/table";
import { Table } from "@/components/ui/table";
import { useTranslation } from "react-i18next";

const ItemSummary = ({
  name,
  quantity,
  description,
  unit_price,
  unit,
}: {
  name: string;
  quantity: number;
  description?: string;
  unit_price: number;
  unit: string;
}) => {
  const { t } = useTranslation();
  return (
    <div className="space-y-2">
      <div className="overflow-x-auto">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="w-[30%]">Item</TableHead>
              <TableHead className="w-[15%]">Quantity</TableHead>
              <TableHead className="w-[15%]">Unit</TableHead>
              <TableHead className="w-[20%]">Unit Price</TableHead>
              <TableHead className="w-[20%]">Total</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow>
              <TableCell className="font-medium">
                <div className="truncate max-w-[200px]" title={name}>
                  {name}
                </div>
                {description && (
                  <div
                    className="text-xs text-gray-500 truncate max-w-[200px]"
                    title={description}
                  >
                    {description}
                  </div>
                )}
              </TableCell>
              <TableCell>{quantity}</TableCell>
              <TableCell>{unit}</TableCell>
              <TableCell>
                {t("common.number_in_currency", {
                  amount: unit_price,
                })}
              </TableCell>
              <TableCell className="font-semibold">
                {t("common.number_in_currency", {
                  amount: quantity * unit_price,
                })}
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </div>
    </div>
  );
};

export { ItemSummary };
