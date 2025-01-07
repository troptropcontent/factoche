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

const ItemGroup = ({ index }: { index: number }) => {
  const { t } = useTranslation();
  const { control, register } = useFormContext<ProjectFormType>();
  const itemArrayFieldName =
    `project_version_attributes.item_groups_attributes.${index}.items_attributes` as const;
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
        <div className="mb-4">
          <Label
            htmlFor={`project_version_attributes.item_groups_attributes.${index}.name`}
          >
            {t("pages.companies.projects.form.item_group_name_input_label")}
          </Label>
          <Input
            {...register(
              `project_version_attributes.item_groups_attributes.${index}.name`
            )}
            placeholder={t(
              "pages.companies.projects.form.item_group_name_input_placeholder"
            )}
          />
        </div>
        {positionnedItems.map((item, itemIndex) => (
          <Item
            key={item.id}
            index={itemIndex}
            parentFieldName={`project_version_attributes.item_groups_attributes.${index}.items_attributes`}
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
