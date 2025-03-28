import { useTranslation } from "react-i18next";
import { useNewInvoiceTotalAmount } from "./form-hooks";
import { FormSubmit } from "@/components/ui/form";

const FormSubmitButton = () => {
  const { t } = useTranslation();

  const newInvoiceAmount = useNewInvoiceTotalAmount();

  return (
    <FormSubmit disabled={newInvoiceAmount == 0}>
      {t("pages.companies.completion_snapshot.form.submit_button_label")}
    </FormSubmit>
  );
};

export { FormSubmitButton };
