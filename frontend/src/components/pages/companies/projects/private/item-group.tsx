import { useFieldArray } from "react-hook-form";

import { useFormContext } from "react-hook-form";
import { ProjectFormType } from "../project-form";
import { Item } from "./item";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardFooter } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { findNextPosition } from "../utils/position-utils";
import { newItem } from "../utils/new-item";
import { useMemo } from "react";
import { Label } from "@/components/ui/label";
import { useTranslation } from "react-i18next";
import { Step2FormType } from "../form-schemas";
import { FormField, FormLabel, FormMessage } from "@/components/ui/form";
import { FormControl } from "@/components/ui/form";
import { FormDescription } from "@/components/ui/form";
import { FormItem } from "@/components/ui/form";

const ItemGroup = ({ index }: { index: number }) => {
  const { t } = useTranslation();
  const { control, register } = useFormContext<Step2FormType>();
  const itemArrayFieldName = `items.${index}.items` as const;
  const { append: addItemToGroup, fields: items } = useFieldArray({
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
    <Card className="mb-4">
      <CardContent className="pt-6">
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
          />
        ))}
      </CardContent>
      <CardFooter>
        <Button variant="outline" type="button" onClick={addNewItemToGroup}>
          {t("pages.companies.projects.form.item_group_add_item_button_label")}
        </Button>
      </CardFooter>
    </Card>
  );
};

export { ItemGroup };
