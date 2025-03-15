import { Button } from "@/components/ui/button";
import { toast } from "@/hooks/use-toast";
import { Api } from "@/lib/openapi-fetch-query-client";
import { Link, useNavigate } from "@tanstack/react-router";
import { Download, Loader2, Pen } from "lucide-react";
import { useTranslation } from "react-i18next";

const EditButton = ({
  invoiceId,
  projectId,
  companyId,
}: {
  invoiceId: number;
  projectId: number;
  companyId: number;
}) => {
  const { t } = useTranslation();
  return (
    <Button asChild variant="outline">
      <Link
        to="/companies/$companyId/projects/$projectId/invoices/$invoiceId/update"
        params={{
          invoiceId: invoiceId.toString(),
          projectId: projectId.toString(),
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

const DownloadInvoicePdfButton = ({
  invoiceId,
  projectId,
}: {
  invoiceId: number;
  projectId: number;
}) => {
  const { t } = useTranslation();
  const { data: invoiceData } = Api.useQuery(
    "get",
    "/api/v1/organization/projects/{project_id}/invoices/{id}",
    {
      params: {
        path: { project_id: projectId, id: invoiceId },
      },
    },
    { select: ({ result }) => result }
  );

  if (invoiceData == undefined) {
    return null;
  }

  const isPdfDownloadable = invoiceData.pdf_url;

  return (
    <Button asChild variant="outline">
      {isPdfDownloadable ? (
        <Link to={`${import.meta.env.VITE_API_BASE_URL}${invoiceData.pdf_url}`}>
          <Download className="mr-2 h-4 w-4" />
          {t(
            "pages.companies.projects.invoices.completion_snapshot.show.actions.download_draft_pdf"
          )}
        </Link>
      ) : (
        <Link disabled>
          <Loader2 className="mr-2 h-4 w-4 animate-spin" />
          {t(
            "pages.companies.projects.invoices.completion_snapshot.show.actions.draft_pdf_unavailable"
          )}
        </Link>
      )}
    </Button>
  );
};

const DownloadCreditNotePdfButton = () => {
  const { t } = useTranslation();

  const isPdfDownloadable = false;

  return (
    <Button asChild variant="outline">
      {isPdfDownloadable ? (
        <Link>
          <Download className="mr-2 h-4 w-4" />
          {t(
            "pages.companies.projects.invoices.completion_snapshot.show.actions.download_credit_note_pdf"
          )}
        </Link>
      ) : (
        <Link disabled>
          <Loader2 className="mr-2 h-4 w-4 animate-spin" />
          {t(
            "pages.companies.projects.invoices.completion_snapshot.show.actions.credit_note_pdf_unavailable"
          )}
        </Link>
      )}
    </Button>
  );
};

const DestroyButton = () => {
  const { t } = useTranslation();

  return (
    <Button variant="destructive">
      {t(
        "pages.companies.projects.invoices.completion_snapshot.show.actions.destroy"
      )}
    </Button>
  );
};

const CancelButton = () => {
  const { t } = useTranslation();

  return (
    <Button variant="destructive">
      {t(
        "pages.companies.projects.invoices.completion_snapshot.show.actions.cancel"
      )}
    </Button>
  );
};

const PostButton = ({
  invoiceId,
  projectId,
  companyId,
}: {
  invoiceId: number;
  projectId: number;
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
        to: "/companies/$companyId/projects/$projectId",
        params: {
          companyId: companyId.toString(),
          projectId: projectId.toString(),
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
        params: { path: { id: invoiceId, project_id: projectId } },
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
  projectId,
  invoiceId,
}: {
  companyId: number;
  projectId: number;
  invoiceId: number;
}) => {
  return (
    <>
      <EditButton
        projectId={projectId}
        invoiceId={invoiceId}
        companyId={companyId}
      />
      <DownloadInvoicePdfButton projectId={projectId} invoiceId={invoiceId} />
      <PostButton
        projectId={projectId}
        invoiceId={invoiceId}
        companyId={companyId}
      />
      <DestroyButton />
    </>
  );
};

const CancelledInvoiceActions = ({
  projectId,
  invoiceId,
}: {
  companyId: number;
  projectId: number;
  invoiceId: number;
}) => {
  return (
    <>
      <DownloadInvoicePdfButton projectId={projectId} invoiceId={invoiceId} />
      <DownloadCreditNotePdfButton />
    </>
  );
};

const PostedInvoiceActions = ({
  projectId,
  invoiceId,
}: {
  companyId: number;
  projectId: number;
  invoiceId: number;
}) => {
  return (
    <>
      <DownloadInvoicePdfButton projectId={projectId} invoiceId={invoiceId} />
      <CancelButton />
    </>
  );
};

const InvoiceActions = ({
  companyId,
  projectId,
  invoiceId,
}: {
  companyId: number;
  projectId: number;
  invoiceId: number;
}) => {
  const { data: invoiceData } = Api.useQuery(
    "get",
    "/api/v1/organization/projects/{project_id}/invoices/{id}",
    {
      params: {
        path: { project_id: projectId, id: invoiceId },
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
                projectId={projectId}
                invoiceId={invoiceId}
              />
            );
          case "posted":
            return (
              <PostedInvoiceActions
                companyId={companyId}
                projectId={projectId}
                invoiceId={invoiceId}
              />
            );
          case "cancelled":
            return (
              <CancelledInvoiceActions
                companyId={companyId}
                projectId={projectId}
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
