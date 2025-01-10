import { Input } from "@/components/ui/input";
import { useFormContext } from "react-hook-form";
import { useTranslation } from "react-i18next";
import { FormField, FormLabel } from "@/components/ui/form";
import { FormControl } from "@/components/ui/form";
import { FormDescription } from "@/components/ui/form";
import { FormMessage } from "@/components/ui/form";
import { FormItem } from "@/components/ui/form";
import { ItemCardLayout } from "./item-card-layout";
import { step2FormSchema } from "../project-form.schema";
import { z } from "zod";

const Item = ({
  parentFieldName,
  index,
  remove,
}: {
  index: number;
  parentFieldName: `items` | `items.${number}.items`;
  remove: () => void;
}) => {
  const fieldName = `${parentFieldName}.${index}` as const;
  const { watch, control } = useFormContext<z.infer<typeof step2FormSchema>>();
  const quantityFieldName = `${fieldName}.quantity` as const;
  const unitPriceFieldName = `${fieldName}.unit_price` as const;
  const nameFieldDame = `${fieldName}.name` as const;
  const unitFieldDame = `${fieldName}.unit` as const;
  const quantityInput = watch(quantityFieldName);
  const unitPriceInput = watch(unitPriceFieldName);
  const { t } = useTranslation();
  return (
    <ItemCardLayout remove={remove}>
      <div className="grid grid-cols-4 gap-4 ">
        <FormField
          control={control}
          name={nameFieldDame}
          render={({ field }) => (
            <FormItem className="col-span-full">
              <FormLabel>
                {t(
                  "pages.companies.projects.form.composition_step.item_name_input_label"
                )}
              </FormLabel>
              <FormControl>
                <Input
                  placeholder={t(
                    "pages.companies.projects.form.composition_step.item_name_input_placeholder"
                  )}
                  {...field}
                />
              </FormControl>
              <FormDescription>
                {t(
                  "pages.companies.projects.form.composition_step.item_name_input_placeholder"
                )}
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={control}
          name={quantityFieldName}
          render={({ field }) => (
            <FormItem>
              <FormLabel>
                {t(
                  "pages.companies.projects.form.composition_step.item_quantity_input_label"
                )}
              </FormLabel>
              <FormControl>
                <Input
                  type="number"
                  {...field}
                  onChange={(e) => field.onChange(Number(e.target.value))}
                />
              </FormControl>
              <FormDescription>
                {t(
                  "pages.companies.projects.form.composition_step.item_quantity_input_description"
                )}
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={control}
          name={unitFieldDame}
          render={({ field }) => (
            <FormItem>
              <FormLabel>
                {t(
                  "pages.companies.projects.form.composition_step.item_unit_input_label"
                )}
              </FormLabel>
              <FormControl>
                <Input
                  placeholder={t(
                    "pages.companies.projects.form.composition_step.item_unit_input_placeholder"
                  )}
                  {...field}
                />
              </FormControl>
              <FormDescription>
                {t(
                  "pages.companies.projects.form.composition_step.item_unit_input_description"
                )}
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormField
          control={control}
          name={unitPriceFieldName}
          render={({ field }) => (
            <FormItem>
              <FormLabel>
                {t(
                  "pages.companies.projects.form.composition_step.item_unit_price_input_label"
                )}
              </FormLabel>
              <FormControl>
                <Input
                  type="number"
                  {...field}
                  onChange={(e) => field.onChange(Number(e.target.value))}
                />
              </FormControl>
              <FormDescription>
                {t(
                  "pages.companies.projects.form.composition_step.item_unit_price_input_description"
                )}
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />
        <FormItem>
          <FormLabel>
            {t("pages.companies.projects.form.item_total_label")}
          </FormLabel>
          <FormControl>
            <Input
              disabled
              value={t("common.number_in_currency", {
                amount: unitPriceInput * quantityInput,
              })}
            />
          </FormControl>
          <FormDescription>
            {t(
              "pages.companies.projects.form.composition_step.item_total_description"
            )}
          </FormDescription>
          <FormMessage />
        </FormItem>
      </div>
    </ItemCardLayout>
  );
};

export { Item };
