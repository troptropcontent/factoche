import { Progress } from "@/components/ui/progress";

const ProgressStepper = <K extends string>({
  steps,
  currentStep,
}: {
  steps: Map<K, string>;
  currentStep: K;
}) => {
  const stepsArray = Array.from(steps);
  const currentStepIndex = stepsArray.findIndex(([key]) => key == currentStep);
  return (
    <div className="px-6 py-2">
      <div className="flex justify-between mb-2">
        {stepsArray.map(([step, label], index) => (
          <span
            key={step}
            className={`text-sm ${
              index === currentStepIndex
                ? "font-medium text-primary"
                : index < currentStepIndex
                  ? "text-primary"
                  : "text-muted-foreground"
            }`}
          >
            {label}
          </span>
        ))}
      </div>
      <Progress
        value={((currentStepIndex + 1) / stepsArray.length) * 100}
        className="w-full"
      />
    </div>
  );
};

export { ProgressStepper };
