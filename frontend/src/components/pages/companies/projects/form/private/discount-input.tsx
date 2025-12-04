import { useFormContext } from "react-hook-form";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useTranslation } from "react-i18next";
import { FormField, FormMessage } from "@/components/ui/form";
import { FormControl } from "@/components/ui/form";
import { FormItem } from "@/components/ui/form";
import { step2FormSchema } from "../project-form.schema";
import { z } from "zod";
import { Trash } from "lucide-react";
import { computeDiscountValue } from "./utils";
import { Card, CardHeader } from "@/components/ui/card";
import { useMemo } from "react";

import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

const DiscountInput = ({
  className,
  discountInputIndex,
  remove,
  update = false,
}: {
  className: string;
  discountInputIndex: number;
  remove: () => void;
  update?: boolean;
}) => {
  const { t } = useTranslation();
  const { control, watch } = useFormContext<z.infer<typeof step2FormSchema>>();
  const inputs = watch();
  const discountValue = useMemo(
    () => computeDiscountValue(inputs, discountInputIndex),
    [inputs, discountInputIndex]
  );
  const discountKind = watch(`discounts.${discountInputIndex}.kind`);

  return (
    <Card className={className}>
      <CardHeader className="flex flex-row items-center gap-4 bg-muted">
        <FormField
          control={control}
          name={`discounts.${discountInputIndex}.name`}
          render={({ field }) => (
            <FormItem className="flex-grow">
              <FormControl>
                <Input
                  placeholder={"Remise commerciale"}
                  className="bg-white"
                  disabled={update}
                  {...field}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={control}
          name={`discounts.${discountInputIndex}.kind`}
          render={({ field }) => (
            <FormItem>
              <FormControl>
                <Select
                  onValueChange={(v) => field.onChange(v)}
                  defaultValue={field.value}
                >
                  <FormControl>
                    <SelectTrigger className="bg-white">
                      <SelectValue
                        placeholder={t(
                          "pages.companies.projects.form.basic_info_step.bank_detail_id_input_placeholder"
                        )}
                      />
                    </SelectTrigger>
                  </FormControl>
                  <SelectContent>
                    <SelectItem value={"percentage"}>
                      {"Pourcentage"}
                    </SelectItem>
                    <SelectItem value={"fixed_amount"}>
                      {"Montant fixe"}
                    </SelectItem>
                  </SelectContent>
                </Select>
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={control}
          name={`discounts.${discountInputIndex}.value`}
          render={({ field }) => (
            <FormItem>
              <FormControl>
                <div className="relative">
                  <Input
                    placeholder={t(
                      "pages.companies.projects.form.composition_step.item_group_name_input_description"
                    )}
                    className="bg-white"
                    type="number"
                    {...field}
                    onChange={(event) => field.onChange(+event.target.value)}
                  />
                  <div className="absolute top-0 right-8 h-full flex items-center">
                    <p>{discountKind === "fixed_amount" ? "€" : "%"}</p>
                  </div>
                </div>
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />
        <p className="min-w-24">
          {t("common.number_in_currency", {
            amount: discountValue,
          })}
        </p>
        <Button variant="outline" type="button" onClick={remove}>
          <Trash />
        </Button>
      </CardHeader>
    </Card>
  );
};

export { DiscountInput };
