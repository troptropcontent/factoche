import { useFormContext } from "react-hook-form";
import { z } from "zod";
import { step2FormSchema } from "../project-form.schema";
import { useMemo } from "react";
import { useTranslation } from "react-i18next";
import { computeTotalDiscountsAndTaxes } from "./utils";
import { Card, CardContent } from "@/components/ui/card";

const ProjectFormTotalWithDiscountsAndTaxes = ({
  className,
}: {
  className?: string;
}) => {
  const form = useFormContext<z.infer<typeof step2FormSchema>>();
  const { t } = useTranslation();
  const formValues = form.watch();
  const { totalWithoutTax, discount, taxes } = useMemo(
    () => computeTotalDiscountsAndTaxes(formValues),
    [formValues]
  );
  const totalAfterDiscount = totalWithoutTax - discount;
  const totalTaxes = taxes.reduce((acc, taxe) => taxe.value + acc, 0);
  const totalTaxesAndDiscountIncludes = totalAfterDiscount + totalTaxes;

  return (
    <Card className={className}>
      <CardContent className="pt-6 flex flex-col gap-4">
        {[
          {
            label: "Sous total HT apres remise",
            value: totalAfterDiscount,
          },
          {
            label: "TVA",
            value: totalTaxes,
          },
          {
            label: "Total TTC",
            value: totalTaxesAndDiscountIncludes,
          },
        ].map((total) => (
          <div className="flex justify-between">
            <p>
              {total.label}
              {" :"}
            </p>
            <p className="text-xl font-bold">
              {t("common.number_in_currency", {
                amount: total.value,
              })}
            </p>
          </div>
        ))}
      </CardContent>
    </Card>
  );
};

export { ProjectFormTotalWithDiscountsAndTaxes };
