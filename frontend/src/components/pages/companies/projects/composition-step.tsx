import { ProjectFormType } from "./project-form";

import { useFieldArray, useFormContext } from "react-hook-form";
import { Button } from "@/components/ui/button";
import { Item } from "./private/item";
import { ItemGroup } from "./private/item-group";
import { newItem } from "./utils/new-item";
import { findNextPosition } from "./utils/position-utils";
import { newItemGroup } from "./utils/new-item-group";
import { useMemo } from "react";
import { t } from "i18next";

const CompositionStep = () => {
  const { control } = useFormContext<ProjectFormType>();
  const { fields: items, append: appendItems } = useFieldArray({
    control,
    name: "project_version_attributes.items_attributes",
  });
  const { fields: itemGroups, append: appendItemGroups } = useFieldArray({
    control,
    name: "project_version_attributes.item_groups_attributes",
  });

  const addNewItemToItems = () => {
    appendItems(newItem(findNextPosition(items, itemGroups)));
  };

  const addNewItemGroupToItemGroups = () => {
    appendItemGroups(newItemGroup(findNextPosition(items, itemGroups)));
  };

  const positionnedItems = useMemo(() => {
    const allItems = [
      ...items.map((item, itemIndex) => ({
        ...item,
        type: "item" as const,
        type_index: itemIndex,
      })),
      ...itemGroups.map((group, groupIndex) => ({
        ...group,
        type: "item_group" as const,
        type_index: groupIndex,
      })),
    ].sort((a, b) => a.position - b.position);

    return allItems;
  }, [items, itemGroups]);

  return (
    <div>
      <ul>
        {positionnedItems.map((item) =>
          item.type === "item" ? (
            <Item
              key={item.id}
              index={item.type_index}
              parentFieldName="project_version_attributes.items_attributes"
            />
          ) : (
            <ItemGroup key={item.id} index={item.type_index} />
          )
        )}
        <div className="hidden only:flex flex-col items-center">
          <p>
            {t("pages.companies.projects.form.composition_empty_state_title")}
          </p>
          <p>
            {t(
              "pages.companies.projects.form.composition_empty_state_description"
            )}
          </p>
        </div>
      </ul>
      <div className="flex justify-between">
        <Button variant="outline" type="button" onClick={addNewItemToItems}>
          {t("pages.companies.projects.form.add_item")}
        </Button>
        <Button
          variant="outline"
          type="button"
          onClick={addNewItemGroupToItemGroups}
        >
          {t("pages.companies.projects.form.add_item_group")}
        </Button>
      </div>
    </div>
  );
};

export { CompositionStep };
