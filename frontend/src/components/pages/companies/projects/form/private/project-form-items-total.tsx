import { useFormContext } from "react-hook-form";
import { z } from "zod";
import { step2FormSchema } from "../project-form.schema";
import { useMemo } from "react";
import { computeItemsTotal } from "../project-form.utils";
import { useTranslation } from "react-i18next";

const ProjectFormItemsTotal = () => {
  const form = useFormContext<z.infer<typeof step2FormSchema>>();
  const { t } = useTranslation();
  const formValues = form.watch();
  const total = useMemo(
    () => computeItemsTotal(formValues.items),
    [formValues]
  );

  return t("pages.companies.projects.form.composition_step.items_total_label", {
    total: t("common.number_in_currency", {
      amount: total,
    }),
  });
};

export { ProjectFormItemsTotal };
