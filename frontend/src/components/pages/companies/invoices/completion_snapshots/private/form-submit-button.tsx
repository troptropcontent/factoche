import { useTranslation } from "react-i18next";
import { Button } from "@/components/ui/button";
import { useNewInvoiceTotalAmount } from "./hooks";

const FormSubmitButton = () => {
  const { t } = useTranslation();

  const newInvoiceAmount = useNewInvoiceTotalAmount();

  return (
    <Button type="submit" disabled={newInvoiceAmount == 0}>
      {t("pages.companies.completion_snapshot.form.submit_button_label")}
    </Button>
  );
};

export { FormSubmitButton };
