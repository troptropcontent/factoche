import { Trans, useTranslation } from "react-i18next";
import { proformaFormSchema } from "./proforma-form-schema";
import { computeProformaAmounts } from "./utils";
import { useWatch } from "react-hook-form";
import { z } from "zod";
import { OrderExtended } from "../../orders/shared/types";

const ProformaFormInvoiceTotalInfo = ({ order }: { order: OrderExtended }) => {
  const { t } = useTranslation();

  const formValues = useWatch<z.infer<typeof proformaFormSchema>>();
  const { discountsAmount, invoiceAmount, itemsAmount } =
    computeProformaAmounts(formValues, order);

  return (
    <p>
      <Trans
        i18nKey="pages.companies.proformas.form.total_info"
        values={{
          invoice_amount: t("common.number_in_currency", {
            amount: invoiceAmount,
          }),
          items_amount: t("common.number_in_currency", {
            amount: itemsAmount,
          }),
          discounts_amount: t("common.number_in_currency", {
            amount: -discountsAmount,
          }),
        }}
      />
    </p>
  );
};

export { ProformaFormInvoiceTotalInfo };
