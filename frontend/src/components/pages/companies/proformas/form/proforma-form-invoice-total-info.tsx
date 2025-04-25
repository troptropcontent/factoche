import { Trans, useTranslation } from "react-i18next";
import { proformaFormSchema } from "./proforma-form-schema";
import { computeProformaAmount } from "./utils";
import { useWatch } from "react-hook-form";
import { z } from "zod";

const ProformaFormInvoiceTotalInfo = () => {
  const { t } = useTranslation();

  const formValues = useWatch<z.infer<typeof proformaFormSchema>>();
  const newProformaAmount = computeProformaAmount(formValues);

  return (
    <p>
      <Trans
        i18nKey="pages.companies.projects.invoices.completion_snapshot.form.total_info"
        values={{
          total: t("common.number_in_currency", {
            amount: newProformaAmount,
          }),
        }}
      />
    </p>
  );
};

export { ProformaFormInvoiceTotalInfo };
