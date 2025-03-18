import { Button } from "@/components/ui/button";
import { toast } from "@/hooks/use-toast";
import { Api } from "@/lib/openapi-fetch-query-client";
import { Link, useNavigate } from "@tanstack/react-router";
import { Download, Loader2, Pen } from "lucide-react";
import { useTranslation } from "react-i18next";

const EditButton = ({
  invoiceId,
  orderId,
  companyId,
}: {
  invoiceId: number;
  orderId: number;
  companyId: number;
}) => {
  const { t } = useTranslation();
  return (
    <Button asChild variant="outline">
      <Link
        to="/companies/$companyId/orders/$orderId/invoices/$invoiceId/update"
        params={{
          invoiceId: invoiceId.toString(),
          orderId: orderId.toString(),
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

type DownloadInvoicePdfButtonProps = {
  type: "proforma" | "invoice" | "credit_note";
} & (
  | {
      url?: string;
      invoiceId?: never;
      orderId?: never;
    }
  | {
      url?: never;
      invoiceId: number;
      orderId: number;
    }
);

const DownloadInvoicePdfButton = ({
  invoiceId,
  orderId,
  type,
  url,
}: DownloadInvoicePdfButtonProps) => {
  const { t } = useTranslation();
  const { data: invoiceData } = Api.useQuery(
    "get",
    "/api/v1/organization/projects/{project_id}/invoices/{id}",
    {
      params: {
        path: { project_id: orderId as number, id: invoiceId as number },
      },
    },
    {
      select: ({ result }) => result,
      enabled: orderId != undefined && invoiceId != undefined,
    }
  );

  const documentUrl = url ? url : invoiceData?.pdf_url;

  return (
    <Button asChild variant="outline">
      {documentUrl ? (
        <Link to={`${import.meta.env.VITE_API_BASE_URL}${documentUrl}`}>
          <Download className="mr-2 h-4 w-4" />
          {t(
            `pages.companies.projects.invoices.completion_snapshot.show.actions.download_${type}_pdf`
          )}
        </Link>
      ) : (
        <Link disabled>
          <Loader2 className="mr-2 h-4 w-4 animate-spin" />
          {t(
            `pages.companies.projects.invoices.completion_snapshot.show.actions.${type}_pdf_unavailable`
          )}
        </Link>
      )}
    </Button>
  );
};

const DestroyButton = ({
  invoiceId,
  orderId,
  companyId,
}: {
  invoiceId: number;
  orderId: number;
  companyId: number;
}) => {
  const { t } = useTranslation();
  const { mutate: voidInvoiceMutation } = Api.useMutation(
    "delete",
    "/api/v1/organization/projects/{project_id}/invoices/{id}"
  );
  const navigate = useNavigate();

  const voidInvoice = () => {
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
          orderId: orderId.toString(),
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

    voidInvoiceMutation(
      {
        params: { path: { id: invoiceId, project_id: orderId } },
      },
      {
        onSuccess,
        onError,
      }
    );
  };

  return (
    <Button variant="destructive" onClick={voidInvoice}>
      {t(
        "pages.companies.projects.invoices.completion_snapshot.show.actions.void"
      )}
    </Button>
  );
};

const CancelButton = ({
  invoiceId,
  orderId,
  companyId,
}: {
  invoiceId: number;
  orderId: number;
  companyId: number;
}) => {
  const { t } = useTranslation();
  const { mutate: cancelInvoiceMutation } = Api.useMutation(
    "post",
    "/api/v1/organization/projects/{project_id}/invoices/{id}/cancel"
  );
  const navigate = useNavigate();

  const cancelInvoice = () => {
    const onSuccess = () => {
      toast({
        title: t(
          "pages.companies.projects.invoices.completion_snapshot.show.actions.cancel_success_toast_title"
        ),
        description: t(
          "pages.companies.projects.invoices.completion_snapshot.show.actions.cancel_success_toast_description"
        ),
      });
      navigate({
        to: "/companies/$companyId/orders/$orderId",
        params: {
          companyId: companyId.toString(),
          orderId: orderId.toString(),
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

    cancelInvoiceMutation(
      {
        params: { path: { id: invoiceId, project_id: orderId } },
      },
      {
        onSuccess,
        onError,
      }
    );
  };

  return (
    <Button variant="destructive" onClick={cancelInvoice}>
      {t(
        "pages.companies.projects.invoices.completion_snapshot.show.actions.cancel"
      )}
    </Button>
  );
};

const PostButton = ({
  invoiceId,
  orderId,
  companyId,
}: {
  invoiceId: number;
  orderId: number;
  companyId: number;
}) => {
  const { t } = useTranslation();
  const { mutate: postInvoiceMutation } = Api.useMutation(
    "post",
    "/api/v1/organization/projects/{project_id}/invoices/{id}"
  );
  const navigate = useNavigate();

  const postInvoice = () => {
    const onSuccess = () => {
      toast({
        title: t(
          "pages.companies.projects.invoices.completion_snapshot.show.actions.post_success_toast_title"
        ),
        description: t(
          "pages.companies.projects.invoices.completion_snapshot.show.actions.post_success_toast_description"
        ),
      });
      navigate({
        to: "/companies/$companyId/orders/$orderId",
        params: {
          companyId: companyId.toString(),
          orderId: orderId.toString(),
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

    postInvoiceMutation(
      {
        params: { path: { id: invoiceId, project_id: orderId } },
      },
      {
        onSuccess,
        onError,
      }
    );
  };

  return (
    <Button variant="default" onClick={postInvoice}>
      {t(
        "pages.companies.projects.invoices.completion_snapshot.show.actions.post"
      )}
    </Button>
  );
};

const DraftInvoiceActions = ({
  companyId,
  orderId,
  invoiceId,
}: {
  companyId: number;
  orderId: number;
  invoiceId: number;
}) => {
  return (
    <>
      <EditButton
        orderId={orderId}
        invoiceId={invoiceId}
        companyId={companyId}
      />
      <DownloadInvoicePdfButton
        orderId={orderId}
        invoiceId={invoiceId}
        type="proforma"
      />
      <PostButton
        orderId={orderId}
        invoiceId={invoiceId}
        companyId={companyId}
      />
      <DestroyButton
        orderId={orderId}
        invoiceId={invoiceId}
        companyId={companyId}
      />
    </>
  );
};

const CancelledInvoiceActions = ({
  orderId,
  invoiceId,
}: {
  companyId: number;
  orderId: number;
  invoiceId: number;
}) => {
  const { data: invoiceData } = Api.useQuery(
    "get",
    "/api/v1/organization/projects/{project_id}/invoices/{id}",
    {
      params: {
        path: { project_id: orderId, id: invoiceId },
      },
    },
    { select: ({ result }) => result }
  );

  const creditNoteUrl = invoiceData?.credit_note?.pdf_url
    ? invoiceData?.credit_note?.pdf_url
    : undefined;

  return (
    <>
      <DownloadInvoicePdfButton
        orderId={orderId}
        invoiceId={invoiceId}
        type="invoice"
      />

      <DownloadInvoicePdfButton url={creditNoteUrl} type="credit_note" />
    </>
  );
};

const PostedInvoiceActions = ({
  companyId,
  orderId,
  invoiceId,
}: {
  companyId: number;
  orderId: number;
  invoiceId: number;
}) => {
  return (
    <>
      <DownloadInvoicePdfButton
        orderId={orderId}
        invoiceId={invoiceId}
        type="invoice"
      />
      <CancelButton
        orderId={orderId}
        invoiceId={invoiceId}
        companyId={companyId}
      />
    </>
  );
};

const InvoiceActions = ({
  companyId,
  orderId,
  invoiceId,
}: {
  companyId: number;
  orderId: number;
  invoiceId: number;
}) => {
  const { data: invoiceData } = Api.useQuery(
    "get",
    "/api/v1/organization/projects/{project_id}/invoices/{id}",
    {
      params: {
        path: { project_id: orderId, id: invoiceId },
      },
    },
    { select: ({ result }) => result }
  );

  if (invoiceData == undefined) {
    return null;
  }

  return (
    <div className="flex flex-col gap-4">
      {(() => {
        switch (invoiceData.status) {
          case "draft":
            return (
              <DraftInvoiceActions
                companyId={companyId}
                orderId={orderId}
                invoiceId={invoiceId}
              />
            );
          case "posted":
            return (
              <PostedInvoiceActions
                companyId={companyId}
                orderId={orderId}
                invoiceId={invoiceId}
              />
            );
          case "cancelled":
            return (
              <CancelledInvoiceActions
                companyId={companyId}
                orderId={orderId}
                invoiceId={invoiceId}
              />
            );
          default:
            throw new Error(`Unhandled invoice status: ${invoiceData.status}`);
        }
      })()}
    </div>
  );
};

export { InvoiceActions };
