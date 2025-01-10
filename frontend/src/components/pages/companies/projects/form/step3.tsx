import { Button } from "@/components/ui/button";
import { projectFormMachine } from "./project-form.machine";
import { EventFromLogic } from "xstate";
import { useTranslation } from "react-i18next";

const Step3 = ({
  send,
}: {
  send: (e: EventFromLogic<typeof projectFormMachine>) => void;
}) => {
  const { t } = useTranslation();
  return (
    <Button
      onClick={() => {
        send({
          type: "GO_FROM_STEP_3_TO_STEP_2",
        });
      }}
    >
      {t("pages.companies.projects.form.previous_button_label")}
    </Button>
  );
};

export { Step3 };
