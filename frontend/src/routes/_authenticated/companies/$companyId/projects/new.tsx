import { Layout } from "@/components/pages/companies/layout";
import { BasicInfoStep } from "@/components/pages/companies/projects/basic-info-step";
import { CompositionStep } from "@/components/pages/companies/projects/composition-step";

import {
  Step1FormDataSchema,
  Step2FormDataSchema,
} from "@/components/pages/companies/projects/form-schemas";
import { FormProgress } from "@/components/pages/companies/projects/private/form-progress";
import { createFileRoute } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";
import { z } from "zod";

const step1SearchSchema = z.object({
  step: z.literal(0),
  initialValues: Step1FormDataSchema.optional(),
  previousStepFormData: z.undefined(),
  nextStepFormData: Step2FormDataSchema.optional(),
});

const step2SearchSchema = z.object({
  step: z.literal(1),
  initialValues: Step2FormDataSchema.optional(),
  previousStepFormData: Step1FormDataSchema,
  nextStepFormData: z.undefined(),
});

const step3SearchSchema = z.object({
  step: z.literal(2),
  initialValues: z.undefined(),
  previousStepFormData: Step2FormDataSchema,
  nextStepFormData: z.undefined(),
});

const searchSchema = z
  .union([step1SearchSchema, step2SearchSchema, step3SearchSchema])
  .catch({ step: 0, initialValues: undefined });

export const Route = createFileRoute(
  "/_authenticated/companies/$companyId/projects/new"
)({
  component: RouteComponent,
  validateSearch: searchSchema,
});

function RouteComponent() {
  const { t } = useTranslation();
  const { companyId } = Route.useParams();
  const { step, previousStepFormData, initialValues } = Route.useSearch();
  console.log("IN RouteComponent");

  return (
    <Layout.Root>
      <Layout.Header>
        <h1 className="text-3xl font-bold">
          {t("pages.companies.projects.new.title")}
        </h1>
      </Layout.Header>
      <Layout.Content>
        <FormProgress currentStep={step} />
        {step == 0 && (
          <BasicInfoStep companyId={companyId} initialValues={initialValues} />
        )}
        {step == 1 && (
          <CompositionStep
            companyId={companyId}
            previousStepFormData={previousStepFormData}
          />
        )}
        {step == 2 && "ConfirmationStep"}
      </Layout.Content>
    </Layout.Root>
  );
}
