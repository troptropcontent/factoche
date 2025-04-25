import { useTranslation } from "react-i18next";

import { FormSubmit } from "@/components/ui/form";
import { computeProformaAmount } from "./utils";
import { proformaFormSchema } from "./proforma-form-schema";
import { z } from "zod";
import { useWatch } from "react-hook-form";

const ProformaFormSubmitButton = () => {
  const { t } = useTranslation();

  const formValues = useWatch<z.infer<typeof proformaFormSchema>>();
  const newProformaAmount = computeProformaAmount(formValues);

  return (
    <FormSubmit disabled={newProformaAmount == 0}>
      {t("pages.companies.completion_snapshot.form.submit_button_label")}
    </FormSubmit>
  );
};

export { ProformaFormSubmitButton };
