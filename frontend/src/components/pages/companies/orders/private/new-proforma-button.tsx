import { PlusCircle } from "lucide-react";

import { Button } from "@/components/ui/button";
import { Link } from "@tanstack/react-router";
import { useTranslation } from "react-i18next";
import { Api } from "@/lib/openapi-fetch-query-client";
import { t } from "i18next";

const ButtonContent = () => {
  const { t } = useTranslation();
  return (
    <>
      <PlusCircle className="h-4 w-4" />
      {t("pages.companies.projects.show.new_completion_snapshot")}
    </>
  );
};

const NewProformaButton = ({
  companyId,
  orderId,
}: {
  companyId: number;
  orderId: number;
}) => {
  const { data: orderProformas } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/proformas",
    {
      params: {
        path: { company_id: companyId },
        query: { order_id: orderId },
      },
    },
    { select: ({ results }) => results }
  );

  const isButtonEnable =
    orderProformas != undefined &&
    !orderProformas.some(({ status }) => status === "draft");

  return (
    <div className="w-full">
      <Button
        disabled={!isButtonEnable}
        asChild={isButtonEnable}
        className="text-wrap w-full"
      >
        {isButtonEnable ? (
          <Link
            to={`/companies/$companyId/orders/$orderId/proformas/new`}
            params={{
              companyId: companyId.toString(),
              orderId: orderId.toString(),
            }}
          >
            <ButtonContent />
          </Link>
        ) : (
          <ButtonContent />
        )}
      </Button>
      {!isButtonEnable && (
        <p className="text-xs text-muted-foreground mt-2 text-center">
          {t(
            "pages.companies.orders.show.invoices_summary.new_proforma_button.disabled_hint"
          )}
        </p>
      )}
    </div>
  );
};

export { NewProformaButton };
