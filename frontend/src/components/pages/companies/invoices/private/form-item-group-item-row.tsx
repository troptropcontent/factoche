import { Input } from "@/components/ui/input";
import { TableCell, TableRow } from "@/components/ui/table";
import { useTranslation } from "react-i18next";
import { useCompletionSnapshotInvoiceItemRow } from "./form-hooks";

interface FormItemGroupItemRowProps {
  item: {
    id: number;
    name: string;
    description?: string | null;
    quantity: number;
    unit_price_amount: number;
    unit: string;
    original_item_uuid: string;
  };
  projectId: number;
}

const FormItemGroupItemRow = ({
  item,
  projectId,
}: FormItemGroupItemRowProps) => {
  const { t } = useTranslation();
  const {
    rowTotal,
    currentCompletionAmount,
    currentCompletionPercentage,
    updateItemInputInvoiceAmount,
    previouslyInvoicedAmount,
    newInvoiceAmount,
    newInvoicePercentage,
    isLoading: isCompletionSnapshotInvoiceItemRowLoading,
  } = useCompletionSnapshotInvoiceItemRow({ item, projectId });

  if (isCompletionSnapshotInvoiceItemRowLoading == true) {
    return null;
  }

  return (
    <TableRow>
      <TableCell className="max-w-[200px] text-wrap">
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
              amount: item.unit_price_amount,
            })}
          </p>
        </div>
      </TableCell>
      <TableCell>
        {t("common.number_in_currency", {
          amount: rowTotal,
        })}
      </TableCell>
      <TableCell className="text-center">
        {t("common.number_in_currency", {
          amount: previouslyInvoicedAmount,
        })}
      </TableCell>
      <TableCell className="text-center">
        {t("common.number_in_percentage", {
          amount: currentCompletionPercentage,
        })}
      </TableCell>
      <TableCell className="text-center">
        {t("common.number_in_currency", {
          amount: currentCompletionAmount,
        })}
      </TableCell>
      <TableCell className="text-center">
        <div className="relative w-20">
          <Input
            type="number"
            min={currentCompletionPercentage}
            max={100}
            className="pr-6"
            onChange={({ target: { value } }) =>
              updateItemInputInvoiceAmount(value)
            }
            defaultValue={newInvoicePercentage}
          />
          <span className="absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
            %
          </span>
        </div>
      </TableCell>
      <TableCell className="text-right">
        {t("common.number_in_currency", {
          amount: newInvoiceAmount,
        })}
      </TableCell>
    </TableRow>
  );
};

export { FormItemGroupItemRow };
