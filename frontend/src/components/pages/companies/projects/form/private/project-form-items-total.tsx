import { useFormContext } from "react-hook-form";
import { z } from "zod";
import { step2FormSchema } from "../project-form.schema";
import { useMemo } from "react";
import { useTranslation } from "react-i18next";
import { computeTotal } from "./utils";
import { Card, CardContent } from "@/components/ui/card";

const ProjectFormItemsTotal = ({ className }: { className?: string }) => {
  const form = useFormContext<z.infer<typeof step2FormSchema>>();
  const { t } = useTranslation();
  const formValues = form.watch();
  const total = useMemo(() => computeTotal(formValues.items), [formValues]);

  return (
    <Card className={className}>
      <CardContent className="pt-6 flex justify-between items-center">
        <p>
          {t(
            "pages.companies.projects.form.composition_step.items_total_label"
          )}
        </p>
        <p className="text-xl font-bold">
          {t("common.number_in_currency", {
            amount: total,
          })}
        </p>
      </CardContent>
    </Card>
  );
};

export { ProjectFormItemsTotal };
