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
import { FileDiff, Plus } from "lucide-react";
import { EmptyState } from "@/components/ui/empty-state";
import { newGroupInput } from "./private/utils";

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
    fields: groups,
    append: appendGroups,
    remove: removeGroupWithIndex,
  } = useFieldArray({
    control: form.control,
    name: "groups",
  });

  const addNewGroupInput = () => {
    appendGroups(newGroupInput(findNextPosition(groups)));
  };

  const positionnedGroups = groups.sort((a, b) => a.position - b.position);

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
        {positionnedGroups.length > 0 ? (
          <>
            {positionnedGroups.map((group, index) => (
              <ItemGroup
                uuid={group.uuid}
                key={group.id}
                remove={() => removeGroupWithIndex(index)}
              />
            ))}
            <div className="flex flex-row-reverse justify-between pb-4">
              <Button
                variant="outline"
                type="button"
                onClick={addNewGroupInput}
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
            onAction={addNewGroupInput}
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
          <Button type="submit" disabled={groups.length == 0}>
            {t("pages.companies.projects.form.next_button_label")}
          </Button>
        </div>
      </form>
    </Form>
  );
};

export { Step2 };
