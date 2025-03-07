import { Trans, useTranslation } from "react-i18next";
import { useNewInvoiceTotalAmount } from "./hooks";

const FormInvoiceTotalInfo = () => {
  const { t } = useTranslation();

  const newInvoiceAmount = useNewInvoiceTotalAmount();

  return (
    <p>
      <Trans
        i18nKey="pages.companies.projects.invoices.completion_snapshot.form.total_info"
        values={{
          total: t("common.number_in_currency", {
            amount: newInvoiceAmount,
          }),
        }}
      />
    </p>
  );
};

export { FormInvoiceTotalInfo };
