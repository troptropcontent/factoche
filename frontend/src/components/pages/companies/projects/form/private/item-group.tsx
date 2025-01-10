import { useFieldArray } from "react-hook-form";

import { useFormContext } from "react-hook-form";
import { Item } from "./item";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useMemo } from "react";
import { useTranslation } from "react-i18next";
import { FormField, FormLabel, FormMessage } from "@/components/ui/form";
import { FormControl } from "@/components/ui/form";
import { FormDescription } from "@/components/ui/form";
import { FormItem } from "@/components/ui/form";
import { ItemCardLayout } from "./item-card-layout";
import { step2FormSchema } from "../project-form.schema";
import { z } from "zod";
import { findNextPosition } from "../project-form.utils";
import { newItem } from "../project-form.utils";

const ItemGroup = ({
  index,
  remove,
}: {
  index: number;
  remove: () => void;
}) => {
  const { t } = useTranslation();
  const { control, formState } =
    useFormContext<z.infer<typeof step2FormSchema>>();
  const itemArrayFieldName = `items.${index}.items` as const;
  const {
    append: addItemToGroup,
    fields: items,
    remove: removeItem,
  } = useFieldArray({
    control,
    name: itemArrayFieldName,
  });

  const addNewItemToGroup = () => {
    addItemToGroup(newItem(findNextPosition(items)));
  };

  const positionnedItems = useMemo(
    () => items.sort((a, b) => a.position - b.position),
    [items]
  );

  return (
    <ItemCardLayout remove={remove}>
      <FormField
        control={control}
        name={`items.${index}.name`}
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
      {positionnedItems.map((item, itemIndex) => (
        <Item
          key={item.id}
          index={itemIndex}
          parentFieldName={`items.${index}.items`}
          remove={() => removeItem(itemIndex)}
        />
      ))}
      {items.length === 0 && formState.isSubmitted && (
        <FormMessage className="mb-4">
          {t(
            "pages.companies.projects.form.composition_step.no_items_in_group_error"
          )}
        </FormMessage>
      )}
      <Button variant="outline" type="button" onClick={addNewItemToGroup}>
        {t("pages.companies.projects.form.item_group_add_item_button_label")}
      </Button>
    </ItemCardLayout>
  );
};

export { ItemGroup };
