import { ProjectFormType } from "./project-form";

import {
  SubmitHandler,
  useFieldArray,
  useForm,
  useFormContext,
} from "react-hook-form";
import { Button } from "@/components/ui/button";
import { Item } from "./private/item";
import { ItemGroup } from "./private/item-group";
import { newItem } from "./utils/new-item";
import { findNextPosition } from "./utils/position-utils";
import { newItemGroup } from "./utils/new-item-group";
import { useMemo } from "react";
import { t } from "i18next";
import { z } from "zod";
import { Step1FormDataSchema, Step2FormDataSchema } from "./form-schemas";
import { Link, useNavigate } from "@tanstack/react-router";
import {
  Form,
  FormItem,
  FormField,
  FormControl,
  FormMessage,
  FormLabel,
} from "@/components/ui/form";
import { zodResolver } from "@hookform/resolvers/zod";

type Step2FormType = z.infer<typeof Step2FormDataSchema>;
const CompositionStep = ({
  companyId,
  previousStepFormData,
}: {
  companyId: string;
  previousStepFormData: z.infer<typeof Step1FormDataSchema>;
}) => {
  const form = useForm<Step2FormType>({
    resolver: zodResolver(Step2FormDataSchema),
    defaultValues: {
      items: [],
    },
  });
  const { fields: items, append: appendItems } = useFieldArray({
    control: form.control,
    name: "items",
  });

  const navigate = useNavigate();
  const addNewItemToItems = () => {
    appendItems(newItem(findNextPosition(items)));
  };
  const addNewItemGroupToItemGroups = () => {
    appendItems(newItemGroup(findNextPosition(items)));
  };

  const positionnedItems = useMemo(
    () => items.sort((a, b) => a.position - b.position),
    [items]
  );

  const onSubmit: SubmitHandler<Step2FormType> = (data) => {
    navigate({
      to: "/companies/$companyId/projects/new",
      params: { companyId },
      search: {
        step: 2,
        previousStepsFormData: {
          step1: previousStepFormData,
          step2: data,
        },
      },
    });
  };

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit(onSubmit)}
        className="px-6 flex flex-col flex-grow"
      >
        {positionnedItems.map((item, index) =>
          item.type == "group" ? (
            <ItemGroup key={item.id} index={index} />
          ) : (
            <Item key={item.id} index={index} parentFieldName="items" />
          )
        )}
        {items.length === 0 && form.formState.isSubmitted && (
          <FormMessage className="mb-4">
            {t("pages.companies.projects.form.composition_step.no_items_error")}
          </FormMessage>
        )}
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
        <div className="flex justify-between mt-auto">
          <Button asChild>
            <Link
              to="/companies/$companyId/projects/new"
              params={{ companyId }}
              search={{ step: 0, initialValues: previousStepFormData }}
            >
              {t("pages.companies.projects.form.previous_button_label")}
            </Link>
          </Button>
          <Button type="submit">
            {t("pages.companies.projects.form.next_button_label")}
          </Button>
        </div>
      </form>
    </Form>
  );
};

export { CompositionStep };
