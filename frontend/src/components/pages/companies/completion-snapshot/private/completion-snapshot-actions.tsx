import { Button } from "@/components/ui/button";
import { Api } from "@/lib/openapi-fetch-query-client";
import { Link } from "@tanstack/react-router";
import { Download } from "lucide-react";
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
  return (
    <Button asChild variant="outline">
      <Link
        to="/companies/$companyId/projects/$projectId/completion_snapshots/$completionSnapshotId/edit"
        params={routeParams}
      >
        Edit
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
    <div className="flex flex-col">
      <DownloadInvoicePdfButton {...{ routeParams }} />
    </div>
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
    <div className="flex flex-col">
      {completionSnapshotStatus === "draft" && (
        <>
          <EditButton
            routeParams={{
              companyId: companyId.toString(),
              projectId: projectId.toString(),
              completionSnapshotId: completionSnapshotId.toString(),
            }}
          />
        </>
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
      {completionSnapshotStatus === "cancelled" && "TO DO"}
    </div>
  );
};

export { CompletionSnapshotActions };
