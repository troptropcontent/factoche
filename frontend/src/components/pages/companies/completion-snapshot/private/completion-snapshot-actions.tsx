import { Button } from "@/components/ui/button";
import { toast } from "@/hooks/use-toast";
import { Api } from "@/lib/openapi-fetch-query-client";
import { useQueryClient } from "@tanstack/react-query";
import { Link, useNavigate } from "@tanstack/react-router";
import { Check, Download } from "lucide-react";
import { Loader2 } from "lucide-react";
import { useTranslation } from "react-i18next";

const EditButton = ({
  routeParams,
}: {
  routeParams: {
    companyId: string;
    projectId: string;
    completionSnapshotId: string;
  };
}) => {
  const { t } = useTranslation();
  return (
    <Button asChild variant="outline">
      <Link
        to="/companies/$companyId/projects/$projectId/completion_snapshots/$completionSnapshotId/edit"
        params={routeParams}
      >
        {t("pages.companies.completion_snapshot.show.actions.edit")}
      </Link>
    </Button>
  );
};

const DownloadInvoicePdfButton = ({
  routeParams,
}: {
  routeParams: {
    companyId: string;
    projectId: string;
    completionSnapshotId: string;
  };
}) => {
  const { data: completionSnapshotData } = Api.useQuery(
    "get",
    "/api/v1/organization/completion_snapshots/{id}",
    { params: { path: { id: parseInt(routeParams.completionSnapshotId) } } }
  );
  const { t } = useTranslation();

  const isPdfDownloadable =
    completionSnapshotData != undefined &&
    completionSnapshotData.result.invoice.pdf_url;

  return (
    <Button asChild variant="outline">
      {isPdfDownloadable ? (
        <Link
          to={`${import.meta.env.VITE_API_BASE_URL}${completionSnapshotData.result.invoice.pdf_url}`}
          params={routeParams}
        >
          <Download className="mr-2 h-4 w-4" />
          {t(
            "pages.companies.completion_snapshot.show.actions.download_invoice_pdf"
          )}
        </Link>
      ) : (
        <Link disabled>
          <Loader2 className="mr-2 h-4 w-4 animate-spin" />
          {t(
            "pages.companies.completion_snapshot.show.actions.invoice_pdf_unavailable"
          )}
        </Link>
      )}
    </Button>
  );
};

const DownloadCreditNotePdfButton = ({
  routeParams,
}: {
  routeParams: {
    companyId: string;
    projectId: string;
    completionSnapshotId: string;
  };
}) => {
  const { data: completionSnapshotData } = Api.useQuery(
    "get",
    "/api/v1/organization/completion_snapshots/{id}",
    { params: { path: { id: parseInt(routeParams.completionSnapshotId) } } }
  );
  const { t } = useTranslation();

  const isPdfDownloadable =
    completionSnapshotData != undefined &&
    completionSnapshotData.result.invoice.credit_note != undefined &&
    completionSnapshotData.result.invoice.credit_note.pdf_url != undefined;

  return (
    <Button asChild variant="outline">
      {isPdfDownloadable ? (
        <Link
          to={`${import.meta.env.VITE_API_BASE_URL}${completionSnapshotData.result.invoice.credit_note?.pdf_url}`}
          params={routeParams}
        >
          <Download className="mr-2 h-4 w-4" />
          {t(
            "pages.companies.completion_snapshot.show.actions.download_credit_note_pdf"
          )}
        </Link>
      ) : (
        <Link disabled>
          <Loader2 className="mr-2 h-4 w-4 animate-spin" />
          {t(
            "pages.companies.completion_snapshot.show.actions.credit_note_pdf_unavailable"
          )}
        </Link>
      )}
    </Button>
  );
};

const PublishedActions = ({
  routeParams,
}: {
  routeParams: {
    companyId: string;
    projectId: string;
    completionSnapshotId: string;
  };
}) => {
  return (
    <>
      <DownloadInvoicePdfButton {...{ routeParams }} />
      <CancelButton {...{ routeParams }} />
    </>
  );
};

const PublishButton = ({
  routeParams,
}: {
  routeParams: {
    companyId: string;
    projectId: string;
    completionSnapshotId: string;
  };
}) => {
  const { t } = useTranslation();
  const { mutate: cancelCompletionSnapshotMutation } = Api.useMutation(
    "post",
    "/api/v1/organization/completion_snapshots/{id}/publish"
  );

  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const completionSnapshotQueryKey = Api.queryOptions(
    "get",
    "/api/v1/organization/completion_snapshots/{id}",
    { params: { path: { id: Number(routeParams.completionSnapshotId) } } }
  ).queryKey;

  const triggerCancelCompletionSnapshotMutation = () => {
    cancelCompletionSnapshotMutation(
      {
        params: { path: { id: Number(routeParams.completionSnapshotId) } },
      },
      {
        onError: () => {
          toast({
            variant: "destructive",
            title: t("common.toast.error_title"),
            description: t("common.toast.error_description"),
          });
        },
        onSuccess: (response) => {
          toast({
            description: (
              <span className="flex gap-2">
                <Check className="text-primary" />
                {t(
                  "pages.companies.completion_snapshot.show.actions.publish_completion_snapshot_success_toast_title"
                )}
              </span>
            ),
          });
          queryClient.setQueryData(completionSnapshotQueryKey, response);
          navigate({
            to: "/companies/$companyId/projects/$projectId/completion_snapshots/$completionSnapshotId",
            params: routeParams,
          });
        },
      }
    );
  };

  return (
    <Button variant="default" onClick={triggerCancelCompletionSnapshotMutation}>
      {t(
        "pages.companies.completion_snapshot.show.actions.publish_completion_snapshot"
      )}
    </Button>
  );
};

const CancelButton = ({
  routeParams,
}: {
  routeParams: {
    companyId: string;
    projectId: string;
    completionSnapshotId: string;
  };
}) => {
  const { t } = useTranslation();
  const { mutate: cancelCompletionSnapshotMutation } = Api.useMutation(
    "post",
    "/api/v1/organization/completion_snapshots/{id}/cancel"
  );

  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const completionSnapshotQueryKey = Api.queryOptions(
    "get",
    "/api/v1/organization/completion_snapshots/{id}",
    { params: { path: { id: Number(routeParams.completionSnapshotId) } } }
  ).queryKey;

  const triggerCancelCompletionSnapshotMutation = () => {
    cancelCompletionSnapshotMutation(
      {
        params: { path: { id: Number(routeParams.completionSnapshotId) } },
      },
      {
        onError: () => {
          toast({
            variant: "destructive",
            title: t("common.toast.error_title"),
            description: t("common.toast.error_description"),
          });
        },
        onSuccess: (response) => {
          toast({
            description: (
              <span className="flex gap-2">
                <Check className="text-primary" />
                {t(
                  "pages.companies.completion_snapshot.show.actions.cancel_completion_snapshot_success_toast_title"
                )}
              </span>
            ),
          });
          queryClient.setQueryData(completionSnapshotQueryKey, response);
          navigate({
            to: "/companies/$companyId/projects/$projectId/completion_snapshots/$completionSnapshotId",
            params: routeParams,
          });
        },
      }
    );
  };

  return (
    <Button
      variant="destructive"
      onClick={triggerCancelCompletionSnapshotMutation}
    >
      {t(
        "pages.companies.completion_snapshot.show.actions.cancel_completion_snapshot"
      )}
    </Button>
  );
};

const DraftActions = ({
  routeParams,
}: {
  routeParams: {
    companyId: string;
    projectId: string;
    completionSnapshotId: string;
  };
}) => {
  return (
    <>
      <EditButton {...{ routeParams }} />
      <PublishButton {...{ routeParams }} />
    </>
  );
};

const CancelledActions = ({
  routeParams,
}: {
  routeParams: {
    companyId: string;
    projectId: string;
    completionSnapshotId: string;
  };
}) => {
  return (
    <>
      <DownloadInvoicePdfButton {...{ routeParams }} />
      <DownloadCreditNotePdfButton {...{ routeParams }} />
    </>
  );
};

const CompletionSnapshotActions = ({
  completionSnapshotStatus,
  routeParams: { companyId, completionSnapshotId, projectId },
}: {
  completionSnapshotStatus: "draft" | "published" | "cancelled";
  routeParams: {
    companyId: number;
    projectId: number;
    completionSnapshotId: number;
  };
}) => {
  return (
    <div className="flex flex-col gap-4">
      {completionSnapshotStatus === "draft" && (
        <DraftActions
          routeParams={{
            companyId: companyId.toString(),
            projectId: projectId.toString(),
            completionSnapshotId: completionSnapshotId.toString(),
          }}
        />
      )}
      {completionSnapshotStatus === "published" && (
        <PublishedActions
          routeParams={{
            companyId: companyId.toString(),
            projectId: projectId.toString(),
            completionSnapshotId: completionSnapshotId.toString(),
          }}
        />
      )}
      {completionSnapshotStatus === "cancelled" && (
        <CancelledActions
          routeParams={{
            companyId: companyId.toString(),
            projectId: projectId.toString(),
            completionSnapshotId: completionSnapshotId.toString(),
          }}
        />
      )}
    </div>
  );
};

export { CompletionSnapshotActions };
