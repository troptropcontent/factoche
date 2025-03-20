import { Input } from "@/components/ui/input";
import { useFieldArray, useFormContext } from "react-hook-form";
import { useTranslation } from "react-i18next";
import { FormField, FormLabel } from "@/components/ui/form";
import { FormControl } from "@/components/ui/form";
import { FormDescription } from "@/components/ui/form";
import { FormMessage } from "@/components/ui/form";
import { FormItem } from "@/components/ui/form";
import { ItemCardLayout } from "./item-card-layout";
import { step2FormSchema } from "../project-form.schema";
import { z } from "zod";

const Item = ({ inputId }: { inputId: string }) => {
  const { control, watch } = useFormContext<z.infer<typeof step2FormSchema>>();

  const { fields: itemInputs, remove: removeItemInput } = useFieldArray({
    control: control,
    name: "items",
  });

  const inputIndex = itemInputs.findIndex(
    (itemInput) => itemInput.uuid == inputId
  );

  const fieldName = `items.${inputIndex}` as const;
  const quantityFieldName = `${fieldName}.quantity` as const;
  const unitPriceFieldName = `${fieldName}.unit_price_amount` as const;
  const nameFieldDame = `${fieldName}.name` as const;
  const unitFieldDame = `${fieldName}.unit` as const;
  const taxRateFieldName = `${fieldName}.tax_rate` as const;
  const quantityInput = watch(quantityFieldName);
  const unitPriceInput = watch(unitPriceFieldName);

  const { t } = useTranslation();
  return (
    <ItemCardLayout remove={() => removeItemInput(inputIndex)}>
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
        <FormField
          control={control}
          name={taxRateFieldName}
          render={({ field }) => (
            <FormItem>
              <FormLabel>
                {t(
                  "pages.companies.projects.form.composition_step.tax_rate_input_label"
                )}
              </FormLabel>
              <div className="relative w-24">
                <FormControl>
                  <Input
                    type="number"
                    min={0}
                    max={100}
                    {...field}
                    onChange={(e) => field.onChange(Number(e.target.value))}
                  />
                </FormControl>
                <span className="absolute inset-y-0 right-6 flex items-center pr-2 pointer-events-none">
                  %
                </span>
              </div>
              <FormDescription>
                {t(
                  "pages.companies.projects.form.composition_step.tax_rate_input_description"
                )}
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />
      </div>
    </ItemCardLayout>
  );
};

export { Item };
