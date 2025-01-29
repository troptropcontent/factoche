import { useTranslation } from "react-i18next";

import { completionSnapshotFormSchema } from "./completion-snapshot-form.schemas";

import { z } from "zod";
import { computeCompletionSnapShotTotalCents } from "./completion-snapshot-form.utils";
import { useFormContext } from "react-hook-form";

const TotalInfo = ({
  itemGroups,
}: {
  itemGroups: {
    grouped_items: { id: number; unit_price_cents: number; quantity: number }[];
  }[];
}) => {
  const { t } = useTranslation();
  const { watch } =
    useFormContext<z.infer<typeof completionSnapshotFormSchema>>();

  const { completion_snapshot_items } = watch();

  return (
    <p>
      {t("pages.companies.completion_snapshot.form.total_label", {
        total: t("common.number_in_currency", {
          amount:
            computeCompletionSnapShotTotalCents(
              completion_snapshot_items,
              itemGroups
            ) / 100,
        }),
      })}
    </p>
  );
};

export { TotalInfo };
