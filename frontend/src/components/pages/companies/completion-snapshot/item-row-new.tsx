import { FormControl } from "@/components/ui/form";

import { FormField } from "@/components/ui/form";

import { TableCell } from "@/components/ui/table";

import { TableRow } from "@/components/ui/table";
import { useTranslation } from "react-i18next";
import { useFormContext } from "react-hook-form";
import { z } from "zod";
import { completionSnapshotFormSchema } from "./completion-snapshot-form.schemas";
import { Input } from "@/components/ui/input";

const ItemRowNew = ({
  item,
  previouslyBuiltAmount,
  inputIndex,
}: {
  item: {
    id: number;
    name: string;
    description?: string | null;
    unit: string;
    unit_price_cents: number;
    quantity: number;
  };
  previouslyBuiltAmount: number;
  inputIndex: number;
}) => {
  const { t } = useTranslation();
  const { control, watch } =
    useFormContext<z.infer<typeof completionSnapshotFormSchema>>();

  const itemTotalAmount = (item.quantity * item.unit_price_cents) / 100;

  const previousCompletionPercentageForThisItem =
    previouslyBuiltAmount === 0
      ? "0"
      : Math.round((previouslyBuiltAmount / itemTotalAmount) * 100).toString();

  const fieldName =
    `completion_snapshot_items.${inputIndex}.completion_percentage` as const;
  const fieldValue = watch(fieldName);

  return (
    <TableRow>
      <TableCell>
        <div>
          <p title={item.name} className="truncate">
            {item.name}
          </p>
          {item.description && (
            <p title={item.name} className="truncate">
              {item.description}
            </p>
          )}
          <p
            title={item.name}
            className="truncate text-xs text-muted-foreground"
          >
            {item.quantity} {item.unit}
            {" @ "}
            {t("common.number_in_currency", {
              amount: item.unit_price_cents / 100,
            })}
          </p>
        </div>
      </TableCell>
      <TableCell>
        {t("common.number_in_currency", {
          amount: item.quantity * (item.unit_price_cents / 100),
        })}
      </TableCell>
      <TableCell>
        {t("common.number_in_percentage", {
          amount: previousCompletionPercentageForThisItem,
        })}
      </TableCell>
      <TableCell>
        {t("common.number_in_currency", {
          amount: previouslyBuiltAmount,
        })}
      </TableCell>
      <TableCell>
        <FormField
          control={control}
          name={fieldName}
          render={({ field }) => (
            <FormControl>
              <div className="relative w-20">
                <Input
                  type="number"
                  min={previousCompletionPercentageForThisItem}
                  max={100}
                  {...field}
                  className="pr-6"
                />
                <span className="absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
                  %
                </span>
              </div>
            </FormControl>
          )}
        />
      </TableCell>
      <TableCell>
        {t("common.number_in_currency", {
          amount:
            item.quantity *
            (item.unit_price_cents / 100) *
            (Number(fieldValue) / 100),
        })}
      </TableCell>
    </TableRow>
  );
};

export { ItemRowNew };
