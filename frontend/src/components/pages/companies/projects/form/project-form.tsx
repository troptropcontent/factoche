import { useMachine } from "@xstate/react";
import { projectFormMachine } from "./project-form.machine";
import { ProgressStepper } from "@/components/ui/progress-stepper";
import { useTranslation } from "react-i18next";
import { Step1 } from "./step1";
import { Step2 } from "./step2";
import { Step3 } from "./step3";

const ProjectForm = ({ companyId }: { companyId: string }) => {
  const [
    {
      value: currentMachineState,
      context: {
        formData: {
          name,
          retention_guarantee_rate,
          client_id,
          description,
          items,
        },
      },
    },
    send,
  ] = useMachine(projectFormMachine);
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
                send={send}
                companyId={companyId}
                initialValues={{
                  name,
                  retention_guarantee_rate,
                  client_id,
                  description,
                }}
              />
            );
          case "step2":
            return <Step2 send={send} initialValues={{ items }} />;
          case "completed":
            return <Step3 send={send} />;
          default:
            return null;
        }
      })()}
    </>
  );
};

export { ProjectForm };
