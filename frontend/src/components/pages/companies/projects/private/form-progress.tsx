import { Progress } from "@/components/ui/progress";
import { useTranslation } from "react-i18next";

const steps = ["basic_info", "composition", "confirmation"] as const;

const FormProgress = ({ currentStep }: { currentStep: number }) => {
  const { t } = useTranslation();
  return (
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
            {t(`pages.companies.projects.form.${step}_step.progress_bar_label`)}
          </span>
        ))}
      </div>
      <Progress
        value={((currentStep + 1) / steps.length) * 100}
        className="w-full"
      />
    </div>
  );
};

export { FormProgress };
