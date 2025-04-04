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

const NewInvoiceButton = ({
  companyId,
  orderId,
}: {
  companyId: number;
  orderId: number;
}) => {
  const { data: projectInvoices } = Api.useQuery(
    "get",
    "/api/v1/organization/companies/{company_id}/invoices",
    {
      params: {
        path: { company_id: companyId },
        query: { status: ["cancelled", "draft", "posted"], order_id: orderId },
      },
    },
    { select: ({ results }) => results }
  );

  const isButtonEnable =
    projectInvoices != undefined &&
    !projectInvoices.some(({ status }) => status === "draft");

  return (
    <div className="w-full">
      <Button
        disabled={!isButtonEnable}
        asChild={isButtonEnable}
        className="text-wrap w-full"
      >
        {isButtonEnable ? (
          <Link
            to={`/companies/$companyId/orders/$orderId/invoices/new`}
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
            "pages.companies.projects.show.completion_snapshot_invoices_summary.new_completion_snapshot_invoice_button.disabled_hint"
          )}
        </p>
      )}
    </div>
  );
};

export { NewInvoiceButton };
