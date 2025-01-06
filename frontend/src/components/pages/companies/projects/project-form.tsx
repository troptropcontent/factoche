import { ReactElement, useState } from "react";
import { BasicInfoStep } from "./basic-info-step";
import { CompositionStep } from "./composition-step";
import { ConfirmationStep } from "./confirmation-step";
import { z } from "zod";
import { TFunction } from "i18next";
import { FormProvider, useForm } from "react-hook-form";
import { Button } from "@/components/ui/button";
import { useTranslation } from "react-i18next";
import { Separator } from "@/components/ui/separator";
import { Progress } from "@/components/ui/progress";
import { zodResolver } from "@hookform/resolvers/zod";

const itemsAttributes = (t: TFunction<"translation">) =>
  z.array(
    z.object({
      name: z.string().min(1, t("form.validation.required")),
      description: z.string(),
      unit: z.string(),
      quantity: z.number().min(0, t("form.validation.required")),
      unit_price: z.number().min(0, t("form.validation.required")),
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
      item_groups_attributes: z.array(
        z.object({
          name: z.string().min(1, t("form.validation.required")),
          description: z.string(),
          items_attributes: itemsAttributes(t),
        })
      ),
    }),
  });

type ProjectFormType = z.infer<ReturnType<typeof projectFormSchema>>;

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
        <div className="px-6 py-2">
          <div className="flex justify-between mb-2">
            {steps.map((step, index) => (
              <span
                key={step}
                className={`text-sm ${
                  index === currentStep
                    ? "font-medium text-primary"
                    : index < currentStep
                      ? "text-primary"
                      : "text-muted-foreground"
                }`}
              >
                {t(`pages.companies.projects.form.${step}`)}
              </span>
            ))}
          </div>
          <Progress
            value={((currentStep + 1) / steps.length) * 100}
            className="w-full"
          />
        </div>
        <div className="flex-grow px-6">
          {currentStep === 0 && <BasicInfoStep clients={clients} />}
          {currentStep === 1 && <CompositionStep />}
          {currentStep === 2 && <ConfirmationStep />}
        </div>
        <div className="flex justify-between">
          <Button
            type="button"
            variant="outline"
            onClick={prevStep}
            disabled={currentStep === 0}
          >
            Previous
          </Button>
          {currentStep < steps.length - 1 ? (
            <Button type="button" onClick={nextStep}>
              Next
            </Button>
          ) : (
            <Button type="submit">Submit</Button>
          )}
        </div>
      </form>
    </FormProvider>
  );
};

export { ProjectForm };
export type { ProjectFormType };
