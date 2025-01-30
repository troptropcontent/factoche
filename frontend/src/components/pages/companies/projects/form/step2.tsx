import { Button } from "@/components/ui/button";
import { projectFormMachine } from "./project-form.machine";

import { EventFromLogic } from "xstate";
import { SubmitHandler, useFieldArray } from "react-hook-form";
import { z } from "zod";
import { step2FormSchema } from "./project-form.schema";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { findNextPosition, newItemGroup } from "./project-form.utils";
import { useMemo } from "react";
import { Form } from "@/components/ui/form";
import { useTranslation } from "react-i18next";
import { ProjectFormItemsTotal } from "./private/project-form-items-total";
import { ItemGroup } from "./private/item-group";
import { Item } from "./private/item";
import { FileDiff, Plus } from "lucide-react";
import { EmptyState } from "@/components/ui/empty-state";

const Step2 = ({
  send,
  initialValues,
}: {
  send: (e: EventFromLogic<typeof projectFormMachine>) => void;
  initialValues: z.infer<typeof step2FormSchema>;
}) => {
  const { t } = useTranslation();
  const form = useForm<z.infer<typeof step2FormSchema>>({
    resolver: zodResolver(step2FormSchema),
    defaultValues: initialValues,
  });
  const {
    fields: items,
    append: appendItems,
    remove: removeItemWithIndex,
  } = useFieldArray({
    control: form.control,
    name: "items",
  });

  const addNewItemGroupToItemGroups = () => {
    appendItems(newItemGroup(findNextPosition(items)));
  };

  const positionnedItems = useMemo(
    () => items.sort((a, b) => a.position - b.position),
    [items]
  );

  const onSubmit: SubmitHandler<z.infer<typeof step2FormSchema>> = (data) => {
    send({
      type: "GO_FROM_STEP_2_TO_STEP_3",
      formData: data,
    });
  };

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit(onSubmit)}
        className="px-6 flex flex-col flex-grow"
      >
        {}
        {positionnedItems.length > 0 ? (
          <>
            {positionnedItems.map((item, index) =>
              item.type == "group" ? (
                <ItemGroup
                  key={item.id}
                  index={index}
                  remove={() => removeItemWithIndex(index)}
                />
              ) : (
                <Item
                  key={item.id}
                  index={index}
                  parentFieldName="items"
                  remove={() => removeItemWithIndex(index)}
                />
              )
            )}
            <div className="flex flex-row-reverse justify-between pb-4">
              <Button
                variant="outline"
                type="button"
                onClick={addNewItemGroupToItemGroups}
              >
                <Plus /> {t("pages.companies.projects.form.add_item_group")}
              </Button>
            </div>
          </>
        ) : (
          <EmptyState
            icon={FileDiff}
            title={t(
              "pages.companies.projects.form.composition_step.empty_state.title"
            )}
            description={t(
              "pages.companies.projects.form.composition_step.empty_state.description"
            )}
            actionLabel={t(
              "pages.companies.projects.form.composition_step.empty_state.action_label"
            )}
            onAction={addNewItemGroupToItemGroups}
            className="flex-grow mb-4"
          />
        )}
        <div className="flex justify-between mt-auto">
          <Button
            onClick={() => {
              send({
                type: "GO_FROM_STEP_2_TO_STEP_1",
                formData: form.getValues(),
              });
            }}
          >
            {t("pages.companies.projects.form.previous_button_label")}
          </Button>
          <ProjectFormItemsTotal />
          <Button type="submit" disabled={items.length == 0}>
            {t("pages.companies.projects.form.next_button_label")}
          </Button>
        </div>
      </form>
    </Form>
  );
};

export { Step2 };
