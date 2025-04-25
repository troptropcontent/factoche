import { Button, LoadingButton } from "@/components/ui/button";

import { toast } from "@/hooks/use-toast";
import { Api } from "@/lib/openapi-fetch-query-client";
import { Link, useNavigate } from "@tanstack/react-router";
import { Pen } from "lucide-react";
import { useTranslation } from "react-i18next";
import { ProformaExtended } from "../shared/types";
import { FinancialTransactionPdfDownloadButton } from "../../financial_transactions/shared/financial-transaction-pdf-download-button";

const DownloadProformaPdfButton = ({
  proforma,
}: {
  proforma: ProformaExtended;
}) => {
  const { t } = useTranslation();
  return (
    <FinancialTransactionPdfDownloadButton
      url={proforma.pdf_url}
      urlDefinedText={t(
        `pages.companies.projects.invoices.completion_snapshot.show.actions.download_proforma_pdf`
      )}
      urlUndefinedText={t(
        `pages.companies.projects.invoices.completion_snapshot.show.actions.proforma_pdf_unavailable`
      )}
    />
  );
};

const EditButton = ({
  proforma,
  companyId,
}: {
  proforma: ProformaExtended;
  companyId: number;
}) => {
  const { t } = useTranslation();
  return (
    <Button asChild variant="outline">
      <Link
        to="/companies/$companyId/proformas/$proformaId/edit"
        params={{
          proformaId: proforma.id.toString(),
          companyId: companyId.toString(),
        }}
      >
        <Pen />
        {t(
          "pages.companies.projects.invoices.completion_snapshot.show.actions.edit"
        )}
      </Link>
    </Button>
  );
};

const DestroyButton = ({
  proforma,
  companyId,
}: {
  proforma: ProformaExtended;
  companyId: number;
}) => {
  const { t } = useTranslation();
  const { data: orderVersion } = Api.useQuery(
    "get",
    "/api/v1/organization/project_versions/{id}",
    { params: { path: { id: proforma.holder_id } } },
    { select: ({ result }) => result }
  );
  const { mutateAsync: voidInvoiceMutation } = Api.useMutation(
    "delete",
    "/api/v1/organization/proformas/{id}"
  );
  const navigate = useNavigate();

  const voidInvoice = async () => {
    const onError = () => {
      toast({
        variant: "destructive",
        title: t("common.toast.error_title"),
        description: t("common.toast.error_description"),
      });
    };
    const onSuccess = () => {
      toast({
        title: t(
          "pages.companies.projects.invoices.completion_snapshot.show.actions.void_success_toast_title"
        ),
        description: t(
          "pages.companies.projects.invoices.completion_snapshot.show.actions.void_success_toast_description"
        ),
      });
      navigate({
        to: "/companies/$companyId/orders/$orderId",
        params: {
          companyId: companyId.toString(),
          orderId: orderVersion!.project_id.toString(),
        },
      });
    };

    await voidInvoiceMutation(
      {
        params: { path: { id: proforma.id } },
      },
      {
        onSuccess,
        onError,
      }
    );
  };

  return (
    <LoadingButton
      variant="destructive"
      onClick={voidInvoice}
      disabled={orderVersion === undefined}
    >
      {t(
        "pages.companies.projects.invoices.completion_snapshot.show.actions.void"
      )}
    </LoadingButton>
  );
};

const PostButton = ({
  proforma,
  companyId,
}: {
  proforma: ProformaExtended;
  companyId: number;
}) => {
  const { t } = useTranslation();
  const { mutateAsync: postInvoiceMutation } = Api.useMutation(
    "post",
    "/api/v1/organization/proformas/{id}"
  );
  const navigate = useNavigate();

  const postProforma = async () => {
    const onSuccess = ({ result: { id } }: { result: { id: number } }) => {
      toast({
        title: t(
          "pages.companies.projects.invoices.completion_snapshot.show.actions.post_success_toast_title"
        ),
        description: t(
          "pages.companies.projects.invoices.completion_snapshot.show.actions.post_success_toast_description"
        ),
      });
      navigate({
        to: "/companies/$companyId/invoices/$invoiceId",
        params: {
          companyId: companyId.toString(),
          invoiceId: id.toString(),
        },
      });
    };

    const onError = () => {
      toast({
        variant: "destructive",
        title: t("common.toast.error_title"),
        description: t("common.toast.error_description"),
      });
    };

    await postInvoiceMutation(
      {
        params: { path: { id: proforma.id } },
      },
      {
        onSuccess,
        onError,
      }
    );
  };

  return (
    <LoadingButton variant="default" onClick={postProforma}>
      {t(
        "pages.companies.projects.invoices.completion_snapshot.show.actions.post"
      )}
    </LoadingButton>
  );
};

const DraftProformaActions = ({
  companyId,
  proforma,
}: {
  companyId: number;
  proforma: ProformaExtended;
}) => {
  return (
    <>
      <EditButton proforma={proforma} companyId={companyId} />
      <DownloadProformaPdfButton proforma={proforma} />
      <PostButton proforma={proforma} companyId={companyId} />
      <DestroyButton proforma={proforma} companyId={companyId} />
    </>
  );
};

const VoidedProformaActions = ({
  proforma,
}: {
  proforma: ProformaExtended;
}) => {
  return <DownloadProformaPdfButton proforma={proforma} />;
};

const PostedProformaActions = ({
  proforma,
}: {
  proforma: ProformaExtended;
}) => {
  return (
    <>
      <DownloadProformaPdfButton proforma={proforma} />
    </>
  );
};

const FinancialTransactionShowProformaSpecificContentActions = ({
  proforma,
  companyId,
}: {
  proforma: ProformaExtended;
  companyId: string;
}) => {
  return (
    <div className="flex flex-col gap-4">
      {(() => {
        switch (proforma.status) {
          case "posted":
            return <PostedProformaActions proforma={proforma} />;
          case "draft":
            return (
              <DraftProformaActions
                proforma={proforma}
                companyId={Number(companyId)}
              />
            );
          case "voided":
            return <VoidedProformaActions proforma={proforma} />;
          default:
            throw new Error(`Unhandled proforma status: ${proforma.status}`);
        }
      })()}
    </div>
  );
};

export { FinancialTransactionShowProformaSpecificContentActions };
