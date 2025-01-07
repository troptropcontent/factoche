import { useState } from "react";
import { BasicInfoStep } from "./basic-info-step";
import { CompositionStep } from "./composition-step";
import { ConfirmationStep } from "./confirmation-step";
import { z } from "zod";
import { TFunction } from "i18next";
import { FormProvider, useForm } from "react-hook-form";
import { Button } from "@/components/ui/button";
import { useTranslation } from "react-i18next";
import { zodResolver } from "@hookform/resolvers/zod";
import { FormProgress } from "./private/form-progress";

const positionAttribute = (t: TFunction<"translation">) =>
  z.number().min(0, t("form.validation.required"));

const itemsAttributes = (t: TFunction<"translation">) =>
  z.array(
    z.object({
      name: z.string().min(1, t("form.validation.required")),
      position: positionAttribute(t),
      description: z.string(),
      unit: z.string(),
      quantity: z.number().min(0, t("form.validation.required")),
      unit_price: z.number().min(0, t("form.validation.required")),
    })
  );

const itemGroupsAttributes = (t: TFunction<"translation">) =>
  z.array(
    z.object({
      name: z.string().min(1, t("form.validation.required")),
      position: positionAttribute(t),
      description: z.string(),
      items_attributes: itemsAttributes(t),
    })
  );

const projectFormSchema = (t: TFunction<"translation">) =>
  z.object({
    name: z.string().min(1, t("form.validation.required")),
    description: z.string(),
    client_id: z.number().min(1, t("form.validation.required")),
    project_version_attributes: z.object({
      retention_guarantee_rate: z.number(),
      items_attributes: itemsAttributes(t),
      item_groups_attributes: itemGroupsAttributes(t),
    }),
  });

type ProjectFormType = z.infer<ReturnType<typeof projectFormSchema>>;
type ProjectItemType = z.infer<ReturnType<typeof itemsAttributes>>[number];
type ProjectItemGroupType = z.infer<
  ReturnType<typeof itemGroupsAttributes>
>[number];

const DefaultValues: ProjectFormType = {
  name: "",
  description: "",
  client_id: 0,
  project_version_attributes: {
    retention_guarantee_rate: 0,
    items_attributes: [],
    item_groups_attributes: [],
  },
};

const steps = [
  "basic_info",
  "project_composition",
  "project_confirmation",
] as const;

const FormContent = ({
  currentStep,
  clients,
}: {
  currentStep: number;
  clients: Array<{ id: number; name: string }>;
}) => (
  <div className="flex-grow px-6">
    {currentStep === 0 && <BasicInfoStep clients={clients} />}
    {currentStep === 1 && <CompositionStep />}
    {currentStep === 2 && <ConfirmationStep />}
  </div>
);

const FormFooter = ({
  currentStep,
  steps,
  onNext,
  onPrev,
}: {
  currentStep: number;
  steps: readonly string[];
  onNext: () => void;
  onPrev: () => void;
}) => (
  <div className="flex justify-between">
    <Button
      type="button"
      variant="outline"
      onClick={onPrev}
      disabled={currentStep === 0}
    >
      Previous
    </Button>
    {currentStep < steps.length - 1 ? (
      <Button type="button" onClick={onNext}>
        Next
      </Button>
    ) : (
      <Button type="submit">Submit</Button>
    )}
  </div>
);

const ProjectForm = ({
  initialValues,
  clients,
}: {
  initialValues?: Partial<ProjectFormType>;
  clients: Array<{ id: number; name: string }>;
}) => {
  const [currentStep, setCurrentStep] = useState(0);
  const { t } = useTranslation();
  const internationalizedFormSchema = projectFormSchema(t);
  const form = useForm<ProjectFormType>({
    resolver: zodResolver(internationalizedFormSchema),
    defaultValues: {
      ...DefaultValues,
      ...initialValues,
    },
  });

  const onSubmit = (data: ProjectFormType) => {
    console.log(data);
  };

  const nextStep = () => {
    setCurrentStep((prev) => Math.min(prev + 1, steps.length - 1));
  };

  const prevStep = () => {
    setCurrentStep((prev) => Math.max(prev - 1, 0));
  };

  return (
    <FormProvider {...form}>
      <form
        onSubmit={form.handleSubmit(onSubmit)}
        className="flex flex-col flex-grow gap-4"
      >
        <FormProgress steps={steps} currentStep={currentStep} />
        <FormContent currentStep={currentStep} clients={clients} />
        <FormFooter
          steps={steps}
          currentStep={currentStep}
          onNext={nextStep}
          onPrev={prevStep}
        />
      </form>
    </FormProvider>
  );
};

export { ProjectForm };
export type { ProjectFormType, ProjectItemType, ProjectItemGroupType };
