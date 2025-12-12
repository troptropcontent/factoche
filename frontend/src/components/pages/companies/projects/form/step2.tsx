import { Button } from "@/components/ui/button";
import { projectFormMachine } from "./project-form.machine";

import { EventFromLogic } from "xstate";
import { SubmitHandler, useFieldArray } from "react-hook-form";
import { z } from "zod";
import { step2FormSchema } from "./project-form.schema";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { findNextPosition } from "./project-form.utils";
import { Form } from "@/components/ui/form";
import { useTranslation } from "react-i18next";
import { ProjectFormItemsTotal } from "./private/project-form-items-total";
import { ItemGroup } from "./private/item-group";
import {
  CornerLeftUp,
  CornerRightUp,
  FileDiff,
  Plus,
  Pointer,
  TicketPercent,
} from "lucide-react";
import { EmptyState } from "@/components/ui/empty-state";
import {
  groupAccordionItemValue,
  newGroupInput,
  newDiscountInput,
} from "./private/utils";
import { ImportItemsFromCsvModal } from "./private/import-items-from-csv-modal";
import { useEffect, useState } from "react";
import { Accordion } from "@/components/ui/accordion";
import { ProjectFormTotalWithDiscountsAndTaxes } from "./private/project-form-total-with-discounts-and-taxes";
import { DiscountInput } from "./private/discount-input";

const EmptyStateActions = ({
  addNewGroupInput,
  setInitialFormValues,
}: {
  addNewGroupInput: () => void;
  setInitialFormValues: (
    initialFormValues: z.infer<typeof step2FormSchema>
  ) => void;
}) => {
  const { t } = useTranslation();
  return (
    <div className="flex gap-4">
      <Button variant="outline" onClick={addNewGroupInput}>
        <Pointer />
        {t(
          "pages.companies.projects.form.composition_step.empty_state.action_label"
        )}
      </Button>
      <ImportItemsFromCsvModal setInitialFormValues={setInitialFormValues} />
    </div>
  );
};

const Step2 = ({
  send,
  initialValues,
}: {
  send: (e: EventFromLogic<typeof projectFormMachine>) => void;
  initialValues: z.infer<typeof step2FormSchema>;
}) => {
  const { t } = useTranslation();
  const [initialFormValues, setInitialFormValues] = useState(initialValues);

  const form = useForm<z.infer<typeof step2FormSchema>>({
    resolver: zodResolver(step2FormSchema),
    defaultValues: initialFormValues,
  });

  useEffect(() => {
    form.reset(initialFormValues);
  }, [initialFormValues, form]);

  const {
    fields: groups,
    append: appendGroups,
    remove: removeGroupWithIndex,
  } = useFieldArray({
    control: form.control,
    name: "groups",
  });

  const {
    fields: discounts,
    append: appendDiscounts,
    remove: removeDiscountWithIndex,
  } = useFieldArray({
    control: form.control,
    name: "discounts",
  });

  const addNewGroupInput = () => {
    appendGroups(newGroupInput(findNextPosition(groups)));
  };

  const addNewDiscount = () => {
    appendDiscounts(newDiscountInput(findNextPosition(discounts)));
  };

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
        {groups.length > 0 ? (
          <>
            <Accordion
              type="single"
              collapsible
              defaultValue={groupAccordionItemValue(groups[0]!)}
              className="flex flex-col gap-6"
            >
              {groups.map((group, index) => (
                <ItemGroup
                  uuid={group.uuid}
                  key={group.id}
                  remove={() => removeGroupWithIndex(index)}
                />
              ))}
            </Accordion>
            <div className="flex flex-row-reverse justify-between">
              <Button
                variant="outline"
                type="button"
                onClick={addNewGroupInput}
                className="mt-6 w-full py-6 border-dashed"
              >
                <CornerLeftUp />
                {t("pages.companies.projects.form.add_item_group")}
                <CornerRightUp />
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
            action={
              <EmptyStateActions
                setInitialFormValues={setInitialFormValues}
                addNewGroupInput={addNewGroupInput}
              />
            }
            onAction={addNewGroupInput}
            className="flex-grow mb-4"
          />
        )}
        <ProjectFormItemsTotal className="mt-6" />
        {discounts.length > 0 ? (
          <>
            {discounts.map((discount, index) => (
              <DiscountInput
                className="mt-6"
                discountInputIndex={index}
                key={index}
                remove={() => removeDiscountWithIndex(index)}
                update={discount.original_discount_uuid !== undefined}
              />
            ))}
            <div className="flex flex-row-reverse justify-between pb-4">
              <Button
                variant="outline"
                type="button"
                onClick={addNewDiscount}
                className="mt-6 w-full py-6 border-dashed"
              >
                <CornerLeftUp />
                {t("pages.companies.projects.form.add_discount")}
                <CornerRightUp />
              </Button>
            </div>
          </>
        ) : (
          <EmptyState
            className="mt-6"
            icon={TicketPercent}
            title={"Pas de remises enregistrées"}
            description={
              "Vous pouvez ajouter une remise via le bouton ci dessous"
            }
            action={
              <Button variant="outline" onClick={addNewDiscount}>
                <Plus />
                {"Ajouter une remise"}
              </Button>
            }
          />
        )}
        <ProjectFormTotalWithDiscountsAndTaxes className="mt-6" />
        <div className="flex justify-between mt-6">
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
          <Button type="submit" disabled={groups.length == 0}>
            {t("pages.companies.projects.form.next_button_label")}
          </Button>
        </div>
      </form>
    </Form>
  );
};

export { Step2 };
