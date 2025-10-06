import { Step3 } from "./step3";

import { z } from "zod";
import { formSchema } from "./project-form.schema";
import { newProjectFormMachine } from "./project-form.machine";
import { useMachine } from "@xstate/react";
import { ProgressStepper } from "@/components/ui/progress-stepper";
import { useTranslation } from "react-i18next";
import { Step1 } from "./step1";
import { Step2 } from "./step2";
import { useMemo } from "react";

const ProjectFormContent = ({
  update,
  initialProjectFormValues,
  companyId,
  submitFunction,
}: {
  update?: boolean;
  companyId: string;
  initialProjectFormValues: z.infer<typeof formSchema>;
  submitFunction: (data: z.infer<typeof formSchema>) => void;
}) => {
  const machine = useMemo(
    () => newProjectFormMachine(initialProjectFormValues),
    [initialProjectFormValues]
  );

  const [
    {
      value: currentMachineState,
      context: {
        formData: {
          name,
          retention_guarantee_rate,
          client_id,
          bank_detail_id,
          description,
          items,
          groups,
          address_city,
          address_street,
          address_zipcode,
          po_number,
        },
      },
    },
    send,
  ] = useMachine(machine);
  const { t } = useTranslation();
  const progressSteps = new Map<typeof currentMachineState, string>([
    [
      "step1",
      t(`pages.companies.projects.form.basic_info_step.progress_bar_label`),
    ],
    [
      "step2",
      t(`pages.companies.projects.form.composition_step.progress_bar_label`),
    ],
    [
      "completed",
      t(`pages.companies.projects.form.confirmation_step.progress_bar_label`),
    ],
  ]);

  return (
    <>
      <ProgressStepper
        steps={progressSteps}
        currentStep={currentMachineState}
      />
      {(() => {
        switch (currentMachineState) {
          case "step1":
            return (
              <Step1
                update={update}
                send={send}
                companyId={companyId}
                initialValues={{
                  name,
                  retention_guarantee_rate,
                  client_id,
                  bank_detail_id,
                  description,
                  address_city,
                  address_street,
                  address_zipcode,
                  po_number,
                }}
              />
            );
          case "step2":
            return <Step2 send={send} initialValues={{ items, groups }} />;
          case "completed":
            return (
              <Step3
                send={send}
                companyId={companyId}
                previousStepsData={{
                  bank_detail_id,
                  name,
                  retention_guarantee_rate,
                  client_id,
                  description,
                  items,
                  groups,
                  address_city,
                  address_street,
                  address_zipcode,
                  po_number,
                }}
                submitFunction={submitFunction}
              />
            );
          default:
            return null;
        }
      })()}
    </>
  );
};

export { ProjectFormContent };
