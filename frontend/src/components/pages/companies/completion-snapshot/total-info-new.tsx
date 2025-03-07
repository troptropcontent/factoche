import { useTranslation } from "react-i18next";

import { completionSnapshotFormSchema } from "./completion-snapshot-form.schemas";

import { z } from "zod";
import { computeCompletionSnapShotTotalCents } from "./completion-snapshot-form.utils";
import { useFormContext } from "react-hook-form";

const TotalInfoNew = ({
  itemGroups,
  previouslyInvoicedItems,
}: {
  itemGroups: {
    grouped_items: {
      id: number;
      original_item_uuid: string;
      unit_price_cents: number;
      quantity: number;
    }[];
  }[];
  previouslyInvoicedItems: Record<string, number>;
}) => {
  const { t } = useTranslation();
  const { watch } =
    useFormContext<z.infer<typeof completionSnapshotFormSchema>>();

  const { completion_snapshot_items: completionSnapshotItems } = watch();

  const completionTotalAmount =
    computeCompletionSnapShotTotalCents(completionSnapshotItems, itemGroups) /
    100;

  const previouslyInvoicedItemsAmount = Object.values(
    previouslyInvoicedItems
  ).reduce((sum, value) => sum + value, 0);

  return (
    <p>
      {t(
        "pages.companies.projects.invoices.completion_snapshot.form.total_info",
        {
          total: t("common.number_in_currency", {
            amount: completionTotalAmount - previouslyInvoicedItemsAmount,
          }),
        }
      )}
    </p>
  );
};

export { TotalInfoNew };
