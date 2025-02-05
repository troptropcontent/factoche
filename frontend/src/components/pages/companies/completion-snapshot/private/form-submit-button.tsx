import { useFormContext } from "react-hook-form";
import { z } from "zod";
import { completionSnapshotFormSchema } from "../completion-snapshot-form.schemas";
import { useTranslation } from "react-i18next";
import { Button } from "@/components/ui/button";

const FormSubmitButton = () => {
  const {
    formState: { isDirty },
  } = useFormContext<z.infer<typeof completionSnapshotFormSchema>>();

  const { t } = useTranslation();

  return (
    <Button type="submit" disabled={!isDirty}>
      {t("pages.companies.completion_snapshot.form.submit_button_label")}
    </Button>
  );
};

export { FormSubmitButton };
