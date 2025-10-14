import { useFieldArray } from "react-hook-form";

import { useFormContext } from "react-hook-form";
import { Item } from "./item";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useTranslation } from "react-i18next";
import { FormField, FormLabel, FormMessage } from "@/components/ui/form";
import { FormControl } from "@/components/ui/form";
import { FormDescription } from "@/components/ui/form";
import { FormItem } from "@/components/ui/form";
import { ItemCardLayout } from "./item-card-layout";
import { step2FormSchema } from "../project-form.schema";
import { z } from "zod";
import { Plus } from "lucide-react";
import { newItemInput } from "./utils";
import { findNextPosition } from "../project-form.utils";

const ItemGroup = ({ uuid, remove }: { uuid: string; remove: () => void }) => {
  const { t } = useTranslation();
  const { control, formState, watch } =
    useFormContext<z.infer<typeof step2FormSchema>>();

  const { append: appendItemInputs } = useFieldArray({
    control: control,
    name: "items",
  });

  const watchedItemInputs = watch("items");

  const { fields: groupInputs } = useFieldArray({
    control: control,
    name: "groups",
  });

  const groupInputIndex = groupInputs.findIndex(
    (groupInput) => groupInput.uuid == uuid
  );

  const addNewItemInput = () => {
    const nextPosition = findNextPosition(watchedItemInputs);
    appendItemInputs(newItemInput(nextPosition, uuid));
  };

  const positionnedItems = watchedItemInputs
    .filter((itemInput) => itemInput.group_uuid === uuid)
    .sort((a, b) => a.position - b.position);

  const groupTotal = positionnedItems.reduce(
    (memo, positionnedItem) =>
      memo + positionnedItem.quantity * positionnedItem.unit_price_amount,
    0
  );

  return (
    <ItemCardLayout remove={remove}>
      <FormField
        control={control}
        name={`groups.${groupInputIndex}.name`}
        render={({ field }) => (
          <FormItem className="mb-4 only:mb-0">
            <FormLabel>
              {t(
                "pages.companies.projects.form.composition_step.item_group_name_input_label"
              )}
            </FormLabel>
            <FormControl>
              <Input
                placeholder={t(
                  "pages.companies.projects.form.composition_step.item_group_name_input_placeholder"
                )}
                {...field}
              />
            </FormControl>
            <FormDescription>
              {t(
                "pages.companies.projects.form.composition_step.item_group_name_input_description"
              )}
            </FormDescription>
            <FormMessage />
          </FormItem>
        )}
      />
      {positionnedItems.map((item) => (
        <Item inputId={item.uuid} key={item.uuid} />
      ))}
      {positionnedItems.length === 0 && formState.isSubmitted && (
        <FormMessage className="mb-4">
          {t(
            "pages.companies.projects.form.composition_step.no_items_in_group_error"
          )}
        </FormMessage>
      )}
      <div className="flex items-center justify-between">
        <Button variant="outline" type="button" onClick={addNewItemInput}>
          <Plus />{" "}
          {t("pages.companies.projects.form.item_group_add_item_button_label")}
        </Button>
        <p>
          {t("pages.companies.projects.form.composition_step.item_group_total")}
          {" : "}
          {t("common.number_in_currency", {
            amount: groupTotal,
          })}
        </p>
      </div>
    </ItemCardLayout>
  );
};

export { ItemGroup };
